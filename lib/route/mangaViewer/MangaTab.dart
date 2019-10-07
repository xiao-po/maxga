import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'MangaPageView.dart';

class MangaTabView extends StatelessWidget {

  Map _httpHeaders = <String, String>{
    "Referer": "http://images.dmzj.com/",
  };

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
    return MangaPageView.custom(
      controller: controller,
      onPageChanged: onPageChanged,
      preloadPageCount: 2,
      physics: AlwaysScrollableScrollPhysics(),
      childrenDelegate: SliverChildListDelegate(
        imgUrlList
            .map((url) => Tab(
          child: GestureDetector(
            onDoubleTap: () => print('test'),
            child: CachedNetworkImage(
              imageUrl: url,
              httpHeaders: _httpHeaders,
              fit: BoxFit.fitWidth,
              placeholder: (context, url) => SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }


}
