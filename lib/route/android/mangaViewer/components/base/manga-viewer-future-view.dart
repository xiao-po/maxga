import 'package:flutter/material.dart';
import 'package:maxga/utils/maxga-utils.dart';

class MangaFeatureView extends StatefulWidget {
  final String title;
  final int imageCount;
  final int pageIndex;
  final Animation animation;
  final ValueChanged<double> onPageChange;

  const MangaFeatureView(
      {Key key,
      @required this.title,
      @required this.imageCount,
      @required this.onPageChange,
      @required this.pageIndex,
        @required this.animation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaFeatureViewState();
}

class _MangaFeatureViewState extends State<MangaFeatureView>{


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 56 * (widget.animation.value - 1)),
            child: child,
          ),
          child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: AppBar(
                iconTheme: IconThemeData(color: Colors.grey[400]),
                backgroundColor: Color(0xff263238),
                elevation: 0,
                leading: BackButton(),
                title: Text(
                  widget.title,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              )),
        ),
        AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) => Transform.translate(
              offset: Offset(0, 56 * (1 - widget.animation.value)),
              child: child),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: BottomAppBar(
                color: Color(0xff263238),
                child: Slider(
                  activeColor: theme.accentColor,
                  inactiveColor: theme.accentColor.withAlpha(0x55),
                  onChanged: widget.onPageChange,
                  value: widget.pageIndex.toDouble(),
                  max: (widget.imageCount - 1).toDouble(),
                ),
              )),
        ),
      ],
    );
  }
}
