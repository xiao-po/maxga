import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MangaReadProcess.dart';
import 'package:maxga/route/Drawer/Drawer.dart';
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
    return Scaffold(
      drawer: MaxgaDrawer(),
      appBar: AppBar(
        title: const Text('收藏'),
      ),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => refreshCollections(),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
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
      print(e);
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
        final itemWidth = MediaQuery.of(context).size.width / 3;
        final height = 210;
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: itemWidth / height,
          children: collectedMangaList.map((el) => Material(
            child: InkWell(
              onTap: () => this.startRead(el),
              child: MangaGridItem(
                manga: el,
                tagPrefix: widget.name,
                source: MangaRepoPool.getInstance().getMangaSourceByKey(el.sourceKey),
              ))
            ),
          ).toList(growable: false),
        );
        break;
      case _LoadingState.error:
        break;
      case _LoadingState.empty:
        break;
    }
  }

  startRead(ReadMangaStatus item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {

      return MangaInfoPage(
          coverImageBuilder: (context) => MangaCoverImage(
            source:  MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey),
            url: item.coverImgUrl,
            tagPrefix: widget.name,
            fit: BoxFit.cover,
          ),
          manga: item);
    }));
  }


  refreshCollections() {

  }

}

