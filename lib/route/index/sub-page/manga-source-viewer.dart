
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/route/Drawer/Drawer.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';

import '../../../MangaRepoPool.dart';

class MangaSourceViewer extends StatefulWidget {
  final name = 'MangaSourceViewer';


  @override
  State<StatefulWidget> createState() => MangaSourceViewerState();

}
class MangaSourceViewerState extends State<MangaSourceViewer> {

  int loadStatus = 0;
  List<SimpleMangaInfo> mangaList;
  List<MangaSource> allMangaSource;

  int page = 0;

  @override
  void initState() {
    super.initState();
    allMangaSource = MangaRepoPool.getInstance()?.allDataSource;
    this.getMangaList();
  }

  @override
  Widget build(BuildContext context) {
    const indexPageBackGround = Color(0xfff5f5f5);
    return Scaffold(
      backgroundColor: indexPageBackGround,
      appBar: AppBar(
        title: const Text('MaxGa'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: this.toSearch,
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () => this.deleteUserData(),
          ),
          PopupMenuButton<MangaSource>(
            itemBuilder: (context) => allMangaSource
                .map((el) => PopupMenuItem(
              value: el,
              child: Text(el.name),
            ))
                .toList(),
            onSelected: (value) => changeMangaSource(value),
          )
        ],
      ),
      drawer: MaxgaDrawer(),
      body: buildIndexBody(),
    );
  }

  buildIndexBody() {
    if (loadStatus == 0) {
      return SkeletonCardList();
    } else if (loadStatus == 1) {
      final Color grayFontColor = Color(0xff9e9e9e);
      return ListView.builder(
          itemCount: mangaList.length,
          itemBuilder: (context, index) {
            MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(mangaList[index].sourceKey);
            return MangaCard(
              title: Text(mangaList[index].title),
              extra: MangaInfoCardExtra(
                  manga: mangaList[index],
                  textColor: grayFontColor,
                  source: source
              ),
              cover: MangaCoverImage(
                source: source,
                url: mangaList[index].coverImgUrl,
                tagPrefix: widget.name,
              ),
              onTap: () => this.goMangaInfoPage(mangaList[index]),
            );
          });
    } else if (loadStatus == -1) {
      return ErrorPage(
        '加载失败了呢~~~，\n我们点击之后继续吧',
        onTap: this.getMangaList,
      );
    }
  }

  Center buildProcessIndicator() {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getMangaList() async {
    this.loadStatus = 0;
    try {
      MaxgaDataHttpRepo repo = MangaRepoPool.getInstance().currentDataRepo;
      mangaList = await repo.getLatestUpdate(page);
      page++;
      await Future.delayed(Duration(seconds: 2));
      this.loadStatus = 1;
    } catch (e) {
      this.loadStatus = -1;
      print(e);
    }

    if(mounted) {
      setState(() {});
    }
  }


  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    MangaSource source = MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
          coverImageBuilder: (context) => MangaCoverImage(
            source: source,
            url: item.coverImgUrl,
            tagPrefix: widget.name,
            fit: BoxFit.cover,
          ),
          manga: item);
    }));
  }



  changeMangaSource(MangaSource value) {
    MangaRepoPool.getInstance().changeMangaSource(value);
    this.getMangaList();
    loadStatus = 0;
    if(mounted) {
      setState(() {});
    }
  }

  deleteUserData() {
    MangaReadStorageService.clearStatus();
//    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
//      return TestPage();
//    }));
  }

}