import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import 'components/MangaImagePlaceHolder.dart';

class MangaListViewer extends StatelessWidget {
  final List<String> imageUrlList;
  final Map<String, String> headers;

  const MangaListViewer(
      {Key key, @required this.imageUrlList, @required this.headers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      itemBuilder: (c, index) => CachedNetworkImage(
        imageUrl: imageUrlList[index],
        httpHeaders: headers,
        placeholder: (context, url) => MangaImagePlaceHolder(index: index),
      ),
      itemCount: imageUrlList.length,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 5,color: Colors.transparent,),
    );
  }
}
