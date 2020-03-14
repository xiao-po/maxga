import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/status/update-status.dart';
import 'package:maxga/provider/public/collection-provider.dart';
import 'package:provider/provider.dart';

const _brightnessIconColor = Colors.white;
final _darkIconColor = Colors.white;

class FloatingRefreshButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<CollectionProvider>(builder: (context, provider, child) {
      return _FloatingRefreshButton(
        dark: true,
        onPressed: () => handleUpdateEvent(context, provider),
        updateStatus: provider.updateStatus,
      );
    });
  }

  void handleUpdateEvent(
      BuildContext context, CollectionProvider provider) async {
    final updateStatus = provider.updateStatus;
    switch (updateStatus) {
      case CollectionUpdateStatus.none:
        await updateCollectedManga(provider, context);
        break;
      case CollectionUpdateStatus.success:
        showDialog(
            context: context,
            child: AlertDialog(
              title: const Text("所有的漫画数据已经更新到了最新"),
              content: const Text("是否要继续更新？"),
              actions: <Widget>[
                FlatButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: const Text('继续更新'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await AnimationDelay();
                    await updateCollectedManga(provider, context);
                  },
                ),
              ],
            ));
        break;
      case CollectionUpdateStatus.warning:
        await updateCollectedManga(provider, context);
        break;
      case CollectionUpdateStatus.processing:
        break;
    }
  }

  Future updateCollectedManga(
      CollectionProvider provider, BuildContext context) async {
    await provider.checkAndUpdateCollectManga();
    showResultSnackBar(context, provider);
  }

  showResultSnackBar(BuildContext context, CollectionProvider provider) {
    final result = provider.updateResult;
    Scaffold.of(context).hideCurrentSnackBar();
    if (result.failedCount == 0) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('更新结束，所有的漫画已经全部更新到了最新'),
      ));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('更新结束，但是发现一些漫画数据存在问题'),
          action: SnackBarAction(
            label: "重新更新",
            onPressed: () => updateCollectedManga(provider, context),
          )));
    }
  }
}

class _FloatingRefreshButton extends StatefulWidget {
  final CollectionUpdateStatus updateStatus;
  final VoidCallback onPressed;

  final bool  dark;

  const _FloatingRefreshButton(
      {Key key, @required this.updateStatus, this.onPressed, this.dark})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FloatingRefreshButtonState();
}

class _FloatingRefreshButtonState extends State<_FloatingRefreshButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CollectionUpdateStatus currentStatus;

  Color currentColor;
  Color nextColor;

  @override
  void didUpdateWidget(_FloatingRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentColor = getBackgroundColor(currentStatus);
    nextColor = getBackgroundColor(widget.updateStatus);
    currentStatus = widget.updateStatus;
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    currentStatus = widget.updateStatus;
    currentColor = getBackgroundColor(currentStatus);
    nextColor = getBackgroundColor(currentStatus);
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        currentColor = getBackgroundColor(currentStatus);
        nextColor = getBackgroundColor(getNextStatus(currentStatus));
      }
    });
    currentStatus = widget.updateStatus;
  }

  Color getBackgroundColor(CollectionUpdateStatus status) {
    switch (status) {
      case CollectionUpdateStatus.processing:
        return widget.dark ?  Colors.lightBlue[600] : Colors.lightBlue;
      case CollectionUpdateStatus.success:
        return widget.dark ?  Colors.teal[600] :  Colors.limeAccent[700] ;
      case CollectionUpdateStatus.warning:
        return widget.dark ? Colors.orange[800] : Colors.orange ;
      case CollectionUpdateStatus.none:
      default:
        return widget.dark ? Colors.cyan : Colors.cyan ;
    }
  }

  static CollectionUpdateStatus getNextStatus(CollectionUpdateStatus status) {
    switch (status) {
      case CollectionUpdateStatus.processing:
        return CollectionUpdateStatus.success;
      case CollectionUpdateStatus.success:
        return CollectionUpdateStatus.processing;
      case CollectionUpdateStatus.warning:
        return CollectionUpdateStatus.processing;
      case CollectionUpdateStatus.none:
      default:
      return CollectionUpdateStatus.processing;
    }
  }


  @override
  Widget build(BuildContext context) {
    var icon;
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    var iconColor = isDarkTheme ? _darkIconColor : _brightnessIconColor;

    switch (widget.updateStatus) {
      case CollectionUpdateStatus.processing:
        icon = FloatRefreshLoadingButton();
        break;
      case CollectionUpdateStatus.success:
        icon = Icon(
          Icons.check,
          color: iconColor,
        );
        break;
      case CollectionUpdateStatus.warning:
        icon = Icon(
          Icons.sync_problem,
          color: iconColor,
        );
        break;
      case CollectionUpdateStatus.none:
      default:
        icon = Icon(
          Icons.sync,
          color: iconColor,
        );
    }

    Widget body = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: widget.dark ? Colors.grey[700] : Colors.grey,
            offset: Offset(1.0, 2.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ClipOval(
        child: AnimatedBuilder(
          animation: controller,
          child: icon,
          builder: (context, child) => Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                color: currentColor,
              ),
              ClipOval(
                child: Container(
                  width: (controller?.value ?? 0) * 56,
                  height: (controller?.value ?? 0) * 56,
                  color: nextColor,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onPressed,
      child: body,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class FloatRefreshLoadingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FloatLoadingRefreshButtonState();
}

class _FloatLoadingRefreshButtonState extends State<FloatRefreshLoadingButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 6), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
        controller.forward();
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    var iconColor = isDarkTheme ? _darkIconColor : _brightnessIconColor;
    var icon = AnimatedBuilder(
      animation: controller,
      child: Icon(Icons.sync, color: iconColor),
      builder: (context, child) => Transform.rotate(
        angle: pi * 2 * (1 - controller.value) * 5,
        child: child,
      ),
    );
    return icon;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
