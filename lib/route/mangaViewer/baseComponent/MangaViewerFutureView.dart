
import 'package:flutter/material.dart';

class MangaFeatureView extends StatelessWidget {
  final String title;
  final int imageCount;
  final int pageIndex;
  final ValueChanged<double> onPageChange;

  const MangaFeatureView(
      {Key key,
      @required this.title,
      @required this.imageCount,
      @required this.onPageChange,
      @required this.pageIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: AppBar(
              backgroundColor: Color(0xff263238),
              elevation: 0,
              leading: BackButton(),
              title: Text(title),
            )),
        MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: BottomAppBar(
              color: Color(0xff263238),
              child: Slider(
                onChanged: onPageChange,
                value: pageIndex.toDouble(),
                max: (imageCount - 1).toDouble(),
              ),
            ))
      ],
    );
  }
}
