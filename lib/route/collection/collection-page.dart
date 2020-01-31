import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/provider/CollectionProvider.dart';
import 'package:maxga/route/drawer/drawer.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:provider/provider.dart';

import '../../MangaRepoPool.dart';

class CollectionPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      UpdateService.isTodayChecked().then((v) {
        if (!v) {
          this.checkUpdate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        drawer: MaxgaDrawer(
          active: MaxgaMenuItemType.collect,
        ),
        appBar: AppBar(
          title: const Text('收藏'),
          actions: <Widget>[
            MaxgaSearchButton(),
            MaxgaTestButton(),
          ],
        ),
        key: scaffoldKey,
        body: buildBody(),
      ),
      onWillPop: () => onBack(),
    );
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
      return true;
    }
  }

  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    try {
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
    } catch(e) {
      debugPrint('检查更新失败');
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


  Widget buildBody() {
    CollectionProvider provider = Provider.of<CollectionProvider>(context);
    if (!provider.loadOver) {
      return Container();
    } else if (provider.loadOver && provider.isEmpty) {
      return ErrorPage('您没有收藏的漫画');
    } else {
      double screenWith = MediaQuery
          .of(context)
          .size
          .width;
      double itemMaxWidth = 140;
      double radio = screenWith / itemMaxWidth;
      final double itemWidth = radio.floor() > 3 ? itemMaxWidth : screenWith /
          3;
      final double height = (itemWidth + 20) / 13 * 15 + 40;
      var gridView = GridView.count(
        crossAxisCount: radio.floor() > 3 ? radio.floor() : 3,
        childAspectRatio: itemWidth / height,
        children: provider.collectionMangaList
            .map(
              (el) =>
              Material(
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
      );
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: RefreshIndicator(
            onRefresh: () => this.updateCollectedManga(),
            child: gridView,
          ));
    }
  }



  startRead(Manga item) async {
    Provider.of<CollectionProvider>(context).setMangaNoUpdate(item);
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MangaInfoPage(
          infoUrl: item.infoUrl,
          sourceKey: item.sourceKey,
          coverImageBuilder: (context) =>
              MangaCoverImage(
                source: MangaRepoPool.getInstance()
                    .getMangaSourceByKey(item.sourceKey),
                url: item.coverImgUrl,
                tagPrefix: widget.name,
                fit: BoxFit.cover,
              ));
    }));
  }


  updateCollectedManga() {
    final c = new Completer<bool>();
    updateCollectionAction().then((v) {
      if (!c.isCompleted) {
        c.complete(true);
      }
    });
    Future.delayed(Duration(seconds: 3)).then((v) {
      if (!c.isCompleted) {
        c.complete(true);
      }
    });
    return c.future;
  }

  Future updateCollectionAction() async {
    final CollectionProvider collectionState = Provider.of<CollectionProvider>(
        context);
    final result = await collectionState.checkAndUpdateCollectManga();
    if (result != null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('收藏漫画已经更新结束'),
      ));
    }
  }

}