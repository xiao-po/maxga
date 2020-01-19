import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:maxga/model/manga/MangaSource.dart';

import 'components/base/MangaExtendedPageView.dart';
import 'MangaImage.dart';

typedef MangaImageAnimationListener = void Function();

class MangaTabView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final bool hasPrechapter;
  final CanMovePage canMovePage;
  final List<Widget> children;

  MangaTabView(
      {Key key,
      this.controller,
        this.children,
      this.onPageChanged,
      this.hasPrechapter,
      this.canMovePage,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MangaExtendedPageView.custom(
      controller: controller,
      onPageChanged: onPageChanged,
      canMovePage: canMovePage,
      childrenDelegate: SliverChildListDelegate(children),
    );
  }
}
