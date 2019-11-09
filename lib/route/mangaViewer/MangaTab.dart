import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'baseComponent/MangaExtendedPageView.dart';
import 'MangaImage.dart';


typedef MangaImageAnimationListener = void Function();

class MangaTabView extends StatelessWidget {



  final PageController controller;
  final List<String> imgUrlList;

  final ValueChanged<int> onPageChanged;

  MangaTabView(
      {Key key,
      this.controller,
      this.imgUrlList, this.onPageChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MangaExtendedPageView.custom(
      controller: controller,
      onPageChanged: onPageChanged,
      childrenDelegate: SliverChildListDelegate(
        imgUrlList
            .map((url) => Tab(
          child: MangaImage(
            url: url,
          ),
        ))
            .toList(),
      ),
    );
  }


}
