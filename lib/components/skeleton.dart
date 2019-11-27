import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class SkeletonMangaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return null;
  }

}

/// 骨架屏
class SkeletonList extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int length;
  final IndexedWidgetBuilder builder;

  SkeletonList(
      {this.length: 6, //一般屏幕长度够用
        this.padding = const EdgeInsets.all(7),
        @required this.builder});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
          period: Duration(milliseconds: 1200),
          baseColor: isDark ? Colors.grey[700] : Colors.grey[350],
          highlightColor: isDark ? Colors.grey[500] : Colors.grey[200],
          child: Padding(
              padding: padding,
              child: Column(
                children:
                List.generate(length, (index) => builder(context, index)),
              ))),
    );
  }
}