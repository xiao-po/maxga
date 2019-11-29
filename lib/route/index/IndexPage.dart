import 'dart:async';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/UpdateDialog.dart';
import 'package:maxga/components/skeleton.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
import 'package:maxga/model/MangaSource.dart';
import 'package:maxga/route/Drawer/Drawer.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:maxga/service/UpdateService.dart';

import '../../Application.dart';

class IndexPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int loadStatus = 0;
  List<SimpleMangaInfo> mangaList;
  List<MangaSource> allMangaSource;

  int page = 0;

  @override
  void initState() {
    super.initState();
    allMangaSource = Application.getInstance()?.allDataSource;
    this.getMangaList();
    if (Platform.isAndroid) {
      this.checkUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xfff5f5f5),
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
              icon: Icon(Icons.info),
              onPressed: () => this.outputCollection(),
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
      ),
      onWillPop: () => onBack(),
    );
  }

  buildIndexBody() {
    if (loadStatus == 0) {
      final itemCount = (MediaQuery.of(context).size.height - 100) / 120;
      return SkeletonList(
        length: itemCount.floor(),
        builder: (context, index) => SkeletonCard(),
      );
    } else if (loadStatus == 1) {
      final Color grayFontColor = Color(0xff9e9e9e);

      return ListView.builder(
          itemCount: mangaList.length,
          itemBuilder: (context, index) => MangaCard(
                title: Text(mangaList[index].title),
                extra: MangaInfoCardExtra(
                    manga: mangaList[index], textColor: grayFontColor),
                cover: MangaCoverImage(
                  source: mangaList[index].source,
                  url: mangaList[index].coverImgUrl,
                  tagPrefix: widget.name,
                ),
                onTap: () => this.goMangaInfoPage(mangaList[index]),
              ));
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
    try {
      MaxgaDataHttpRepo repo = Application.getInstance().getMangaSource();
      mangaList = await repo.getLatestUpdate(page);
      page++;
      await Future.delayed(Duration(seconds: 2));
      this.loadStatus = 1;
    } catch (e) {
      this.loadStatus = -1;
      print(e);
      this.showSnack("getMangaList 失败， 页面： $page");
    }

    setState(() {});
  }

  void showSnack(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }

  goMangaInfoPage(SimpleMangaInfo item) {
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

  DateTime _lastPressedAt; //上次点击时间
  Future<bool> onBack() async {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      showSnack('再按一次退出程序');
      return false;
    } else {
      hiddenSnack();
      await Future.delayed(Duration(milliseconds: 100));
      MaxgaUtils.backDeskTop();
      return false;
    }
  }

  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    final nextVersion = await UpdateService.checkUpdateStatus();
    if (nextVersion != null) {
      final buttonTextStyle = TextStyle(
        color: Colors.greenAccent,
      );
      final buttonPadding = EdgeInsets.fromLTRB(15, 5, 15, 5);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('有新版本更新'),
            Row(
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: buttonPadding,
                    child: Text('详情', style: buttonTextStyle),
                  ),
                  onTap: () {
                    hiddenSnack();
                    openUpdateDialog(nextVersion);
                  },
                ),
                GestureDetector(
                  child: Padding(
                    padding: buttonPadding,
                    child: Text('忽略', style: buttonTextStyle),
                  ),
                  onTap: () {
                    hiddenSnack();
                    UpdateService.ignoreUpdate(nextVersion);
                  },
                )
              ],
            ),
          ],
        ),
      ));
    }
  }

  openUpdateDialog(MaxgaReleaseInfo nextVersion) {
    showDialog(
        context: context,
        builder: (context) => UpdateDialog(
              text: nextVersion.description,
              url: nextVersion.url,
              onIgnore: () => UpdateService.ignoreUpdate(nextVersion),
            ));
  }

  changeMangaSource(MangaSource value) {
    Application.getInstance().changeMangaSource(value);
    this.getMangaList();
    loadStatus = 0;
    setState(() {});
  }

  outputCollection() async {
    loadStatus = loadStatus == 1 ? 0 : 1;
    List<ReadMangaStatus> collectedMangaList =
        await MangaReadStorageService.getAllCollectedManga();
    print(''
        '${collectedMangaList.map((el) => el.title).join('\n')}'
        '');
    setState(() {});
  }
}
