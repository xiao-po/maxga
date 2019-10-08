import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MangaExtendedPageView.dart';
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
          child: GestureDetector(
//            child: CachedNetworkImage(
//              imageUrl: url,
//              httpHeaders: _httpHeaders,
//              fit: BoxFit.fitWidth,
//              placeholder: (context, url) => SizedBox(
//                height: 40,
//                width: 40,
//                child: CircularProgressIndicator(strokeWidth: 2),
//              ),
//            ),
            child: MangaImage(
              url: url,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }


}
