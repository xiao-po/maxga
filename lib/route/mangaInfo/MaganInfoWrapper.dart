import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MangaInfoWrapper extends StatefulWidget {

  final String title;

  final List<Widget> children;

  const MangaInfoWrapper({Key key, this.title, this.children}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _MangaInfoWrapperState();
}


class _MangaInfoWrapperState extends State<MangaInfoWrapper> {
  final scrollController = ScrollController();
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(listenScrollTopForModifyBackgroundColor);
  }
  @override
  Widget build(BuildContext context) {

    Color originColor = Theme.of(context).accentColor;
    Color appbarColor = Color.fromARGB((opacity * 0xff).floor(), originColor.red , originColor.green, originColor.blue);
    Color appbarTitleColor = Color.fromARGB((opacity * 0xff).floor(), 0x000000ff, 0x000000ff, 0x000000ff);

    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(widget.children),
            )
          ],
        ),
        Container(
          height: 80,
          child: AppBar(
            backgroundColor: appbarColor,
            title:  Text(widget.title, style: TextStyle(color: appbarTitleColor)),
            elevation: 0,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.share, color: Colors.white), onPressed: () {},)
            ],
          ),
        ),
      ],
    );
  }


  void listenScrollTopForModifyBackgroundColor() {
    if (scrollController.position.extentBefore < 200) {
      var opacity = scrollController.position.extentBefore / 100 ;
      this.opacity = opacity > 0.9 ? 1 : opacity;
      setState(() {});
    }
  }


  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

}
