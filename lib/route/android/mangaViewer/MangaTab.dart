import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';

import 'components/base/MangaExtendedPageView.dart';

typedef MangaImageAnimationListener = void Function();

class MangaTabView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final bool hasPrechapter;
  final CanMovePage canMovePage;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  MangaTabView(
      {Key key,
      this.controller,
        this.itemCount,
        this.itemBuilder,
      this.onPageChanged,
      this.hasPrechapter,
      this.canMovePage,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MangaExtendedPageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      canMovePage: canMovePage,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
    );
  }
}
