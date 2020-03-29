import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import 'base/manga-viewer-divider-width.dart';
import 'components/manga-image-place-holder.dart';

class MangaListViewer extends StatelessWidget {
  final List<String> imageUrlList;
  final Map<String, String> headers;
  final int initialScrollIndex;
  final ItemPositionsListener itemPositionsListener;
  final ItemScrollController itemScrollController;
  final MangaViewerDividerWidth mangaViewerDividerWidth;

  const MangaListViewer(
      {Key key,
      @required this.imageUrlList,
      @required this.headers,
      this.itemPositionsListener,
      this.itemScrollController,
      this.initialScrollIndex,
        this.mangaViewerDividerWidth = MangaViewerDividerWidth.small})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dividerWidth = mangaViewerDividerWidth.index * 3;
    return ScrollablePositionedList.separated(
      itemPositionsListener: itemPositionsListener,
      itemScrollController: itemScrollController,
      initialScrollIndex: initialScrollIndex ?? 0,
      itemBuilder: (c, index) => CachedNetworkImage(
        imageUrl: imageUrlList[index],
        httpHeaders: headers,
        placeholder: (context, url) => Container(
          height: 400,
          width: size.width,
          child:  MangaImagePlaceHolder(index: index),
        ),
      ),
      itemCount: imageUrlList.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: dividerWidth.toDouble(),
        color: Colors.transparent,
      ),
    );
  }
}
