import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'baseComponent/MangaExtendedPageView.dart';
import 'MangaImage.dart';

typedef MangaImageAnimationListener = void Function();

class MangaTabView extends StatelessWidget {
  final PageController controller;
  final List<String> imgUrlList;

  final ValueChanged<int> onPageChanged;

  MangaTabView({Key key, this.controller, this.imgUrlList, this.onPageChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Tab> imageTab = [];
    for(var i = 0; i <= (imgUrlList.length - 1) ; i++  ) {
      var url = imgUrlList[i];
      imageTab.add(
          Tab(
            child: MangaImage(
              url: url,
              index: i + 1,
            ),
          )
      );
    }

    return MangaExtendedPageView.custom(
      controller: controller,
      onPageChanged: onPageChanged,
      childrenDelegate: SliverChildListDelegate(imageTab),
    );
  }
}
