import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/Utils/MaxgaUtils.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/route/Drawer/Drawer.dart';
import 'package:maxga/route/index/sub-page/collection.dart';
import 'package:maxga/route/index/sub-page/manga-source-viewer.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:provider/provider.dart';

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
    if (Platform.isAndroid) {
      this.checkUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        drawer: MaxgaDrawer(),
        key: scaffoldKey,
        body: buildIndexPage(),
      ),
      onWillPop: () => onBack(),
    );
  }

  Widget buildIndexPage() {
    MaxgaMenuItemType type = Provider.of<MaxgaMenuItemType>(context);
    switch (type) {
      case MaxgaMenuItemType.mangaSourceViewer:
        return MangaSourceViewer();
        break;
      case MaxgaMenuItemType.setting:
      case MaxgaMenuItemType.about:
      case MaxgaMenuItemType.history:
      case MaxgaMenuItemType.collect:
      default:
        return CollectionPage();
    }
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
    MangaSource source =
        MangaRepoPool.getInstance().getMangaSourceByKey(item.sourceKey);
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
      final buttonPadding = const EdgeInsets.fromLTRB(15, 5, 15, 5);
      scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          content: GestureDetector(
            child: Padding(
              padding: buttonPadding,
              child: Text('有新版本更新, 点击查看'),
            ),
            onTap: () {
              hiddenSnack();
              openUpdateDialog(nextVersion);
            },
          ),
          action: SnackBarAction(
            label: '忽略',
            textColor: Colors.greenAccent,
            onPressed: () {
              openUpdateDialog(nextVersion);
            },
          )));
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
}