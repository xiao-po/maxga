import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/model/maxga/MangaReadProcess.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

enum _LoadingState { loading, over, error, empty }

class CollectionPage extends StatefulWidget {
  final String name = 'collection-page';

  @override
  State<StatefulWidget> createState() => CollectionPageState();
}

class CollectionPageState extends State<CollectionPage> {
  _LoadingState loadingState = _LoadingState.loading;
  List<ReadMangaStatus> collectedMangaList;

  @override
  void initState() {
    super.initState();
    this.init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppBar(
              title: const Text('收藏'),
              leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer()),
              actions: <Widget>[
                MaxgaSearchButton()
              ],
            ),
            Expanded(
              child: buildBody(),
            )
          ],
        ));
  }

  void init() async {
    try {
      final collectedMangaList =
          await MangaReadStorageService.getAllCollectedManga();
      this.collectedMangaList = collectedMangaList;
      loadingState = collectedMangaList.length > 0
          ? _LoadingState.over
          : _LoadingState.empty;
    } catch (e) {
      debugPrint(e);
      loadingState = _LoadingState.error;
    } finally {
      setState(() {});
    }
  }

  buildBody() {
    switch (loadingState) {
      case _LoadingState.loading:
        return Container();
        break;
      case _LoadingState.over:
        final double itemWidth = 140;
        final double height = 210;
        return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: GridView.extent(
              maxCrossAxisExtent: itemWidth,
              childAspectRatio: itemWidth / height,
              children: collectedMangaList
                  .map(
                    (el) => Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () => this.startRead(el),
                            child: MangaGridItem(
                              manga: el,
                              tagPrefix: widget.name,
                              source: MangaRepoPool.getInstance()
                                  .getMangaSourceByKey(el.sourceKey),
                            ))),
                  )
                  .toList(growable: false),
            ));
        break;
      case _LoadingState.error:
      case _LoadingState.empty:
        return ErrorPage('您没有收藏的漫画');
    }
  }

  startRead(ReadMangaStatus item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
          coverImageBuilder: (context) => MangaCoverImage(
                source: MangaRepoPool.getInstance()
                    .getMangaSourceByKey(item.sourceKey),
                url: item.coverImgUrl,
                tagPrefix: widget.name,
                fit: BoxFit.cover,
              ),
          manga: item);
    }));
  }

  refreshCollections() {}
}
