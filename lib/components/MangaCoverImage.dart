import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MangaCoverImage extends StatelessWidget {
  final String url;
  final String tagPrefix;
  final BoxFit fit;

  const MangaCoverImage({Key key,@required this.url,@required this.tagPrefix,this.fit = BoxFit.contain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${tagPrefix}${url}',
      child: CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          placeholder: (context, url) =>
              CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}