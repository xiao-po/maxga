//import 'package:flutter/cupertino.dart';
//
//import 'MangaViewer.dart';
//import 'baseComponent/MangaViewerFutureView.dart';
//
//class MangaViewerContainer extends StatefulWidget {
//  final Widget child;
//  final MangaStatusBar statusBar;
//  final ValueChanged<double> onPageChange;
//
//  final String title;
//
//  MangaViewerContainer({Key key, this.child, this.statusBar, this.onPageChange}) : super(key: key);
//  @override
//  State<StatefulWidget> createState() => MangaViewerContainerState();
//
//}
//
//class MangaViewerContainerState extends State<MangaViewerContainer> {
//  @override
//  Widget build(BuildContext context) {
//    return  Stack(
//      children: <Widget>[
//        widget.child,
//        widget.statusBar,
//        AnimatedOpacity(
//          opacity: mangaFutureViewOpacity,
//          duration: futureViewAnimationDuration,
//          child: mangaFutureViewVisitable
//              ? MangaFeatureView(
//            onPageChange: widget.onPageChange,
//            imageCount: chapterImageCount,
//            pageIndex: radioPageIndex,
//            title: widget.title,
//          )
//              : null,
//        ),
//      ],
//    );;
//  }
//
//}