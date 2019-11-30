import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/model/MangaReadProcess.dart';
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
      appBar: AppBar(
        title: const Text('MaxGa'),
      ),
      body: buildBody(),
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
              child: SmallMangaCard(manga: el,tagPrefix: widget.name,))
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
            source: item.source,
            url: item.coverImgUrl,
            tagPrefix: widget.name,
            fit: BoxFit.cover,
          ),
          manga: item);
    }));
  }

}

class SmallMangaCard extends StatelessWidget {
  final ReadMangaStatus manga;
  final String tagPrefix;

  const SmallMangaCard(
      {Key key, @required this.manga, @required this.tagPrefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: 130,
              height: 150,
              margin: EdgeInsets.only(bottom: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MangaCoverImage(
                  url: manga.coverImgUrl,
                  source: manga.source,
                  fit: BoxFit.fitWidth,
                  tagPrefix: tagPrefix,
                ),
              )),
          Text(manga.title,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(manga.lastUpdateChapter.title,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, textBaseline: TextBaseline.alphabetic, color: Colors.black45)),
                ),
                Text(manga.source.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12, textBaseline: TextBaseline.alphabetic, color: Colors.black45))
              ],
            ),
          )
        ],
      ),
    );
  }
}
