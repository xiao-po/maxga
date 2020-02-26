import 'package:flutter/material.dart';

class MangaInfoWrapper extends StatefulWidget {
  final String title;

  final List<Widget> children;

  final Widget bottomBar;

  final List<Widget> appbarActions;

  const MangaInfoWrapper({Key key, this.title, this.children, this.bottomBar, this.appbarActions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaInfoWrapperState();
}

class _MangaInfoWrapperState extends State<MangaInfoWrapper> {
  final scrollController = ScrollController();
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() => listenScrollTopForModifyBackgroundColor());
  }

  @override
  Widget build(BuildContext context) {
    Color originColor = Theme.of(context).primaryColor;
    Color appbarColor = Color.fromARGB((opacity * 0xff).floor(),
        originColor.red, originColor.green, originColor.blue);
    var titleColor = Colors.grey[500];
    Color appbarTitleColor = Color.fromARGB(
        (opacity * 0xff).floor(), titleColor.red, titleColor.green, titleColor.blue);

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(widget.children),
                  )
                ],
              ),
            ),
            widget.bottomBar != null
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.bottomBar,
                  )
                : Container()
          ],
        ),
        Container(
          height: 80.0,
          child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: AppBar(
                backgroundColor: appbarColor,
                iconTheme: IconThemeData(color: Colors.grey[400]),
                leading: BackButton(),
                elevation: 0,
                title: Text(widget.title,
                    style: TextStyle(color: appbarTitleColor)),
                actions: widget.appbarActions,
              )),
        ),
      ],
    );
  }

  void listenScrollTopForModifyBackgroundColor() {
    if (scrollController.position.extentBefore < 200) {
      var opacity = scrollController.position.extentBefore / 100;
      setState(() {
        this.opacity = opacity > 0.9 ? 1 : opacity;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
