import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/UpdateDialog.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/Drawer/Drawer.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
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
  List<Manga> mangaList;

  int page = 0;

  @override
  void initState() {
    super.initState();
    this.getMangaList();
    this.checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xfff5f5f5),
        appBar: AppBar(
          title: const Text('maxga'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: this.toSearch,
            ),
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
      return buildProcessIndicator();
    } else if (loadStatus == 1) {
      return ListView(
          children: mangaList
              .map((item) => MangaCard(
                    manga: item,
                    cover: _buildCachedNetworkImage(item),
                    onTap: () => this.goMangaInfoPage(item),
                  ))
              .toList());
    } else if (loadStatus == -1) {
      return ErrorPage(
        '加载失败了呢~~~，\n我们点击之后继续吧',
        onTap: this.getMangaList,
      );
    }
  }

  CachedNetworkImage _buildCachedNetworkImage(Manga item) {
    return CachedNetworkImage(
        imageUrl: item.coverImgUrl,
        placeholder: (context, url) =>
            CircularProgressIndicator(strokeWidth: 2));
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
      MaxgaDataHttpRepo repo = Application.getInstance().currentDataRepo;
      mangaList = await repo.getLatestUpdate(page);
      page++;
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

  goMangaInfoPage(Manga item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        url: item.infoUrl,
        id: item.id,
      );
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
            )
    );
  }
}
