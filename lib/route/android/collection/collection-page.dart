import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/drawer/menu-item.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/components/base/WillExitScope.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/components/dialog.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/provider/public/CollectionProvider.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:maxga/route/android/user/base/LoginPageResult.dart';
import 'package:maxga/route/android/user/login-page.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:provider/provider.dart';

import '../drawer/drawer.dart';
import '../mangaInfo/MangaInfoPage.dart';

class CollectionPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MaxgaReleaseInfo nextVersion;

  bool isShowUpdateBanner = false;
  bool isShowLoginBanner = false;
  bool isShowSyncBanner = false;

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
    if (UserProvider.getInstance().isFirstOpen) {
      this.isShowLoginBanner = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.grey[500];
    return Scaffold(
      drawer: MaxgaDrawer(
        active: MaxgaMenuItemType.collect,
        loginCallback: () => toLogin(),
      ),
      appBar: AppBar(
        title: Text('收藏'),
        elevation: 1,
        actions: <Widget>[
          MaxgaSearchButton(),
          MaxgaTestButton()
        ],
      ),
      key: scaffoldKey,
      body: WillExitScope(
        child: buildBody(),
      ),
    );
  }

  Widget buildUpdateBanner() {
    var body = MaterialBanner(
      content: const Text('有新版本更新, 点击查看'),
      leading: const CircleAvatar(child: Icon(Icons.arrow_upward)),
      actions: <Widget>[
        FlatButton(
          child: const Text('查看'),
          color: Theme.of(context).accentColor,
          onPressed: () {
            openUpdateDialog(nextVersion);
            setState(() {
              isShowUpdateBanner = false;
            });
          },
        ),
        FlatButton(
          color: Theme.of(context).accentColor,
          child: const Text('忽略'),
          onPressed: () {
            UpdateService.ignoreUpdate(nextVersion);
            setState(() {
              isShowUpdateBanner = false;
            });
          },
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: body,
    );
  }

  Widget buildLoginBanner() {
    var body =  MaterialBanner(
      content: const Text('登录后即可享受同步多设备间的阅读数据，不丢失阅读记录'),
      leading: const CircleAvatar(child: Icon(Icons.person_pin)),
      actions: <Widget>[
        FlatButton(
          child: const Text('登录'),
          onPressed: () async {
            await AnimationDelay();
            toLogin();
          },
        ),
        FlatButton(
          child: const Text('忽略'),
          onPressed: () async {
            await AnimationDelay();
            setState(() {
              isShowLoginBanner = false;
            });
          },
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: body,
    );
  }

  Widget buildSyncBanner() {
    var body = MaterialBanner(
      content: const Text('是否立即同步的收藏和阅读记录？'),
      leading: const CircleAvatar(child: Icon(Icons.sync)),
      actions: <Widget>[
        FlatButton(
          child: const Text('同步'),
          onPressed: () async {
            showDialog(context: context, child: CircularProgressDialog(forbidCancel: true, tip: "同步中",));
            try {
              await Future.wait([
                UserProvider.getInstance().sync(),
                AnimationDelay()
              ]);
              setState(() {
                isShowSyncBanner = false;
              });
            } catch(e) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("同步出现问题"),
              ));
            } finally {

              Navigator.of(context).pop();
            }
          },
        ),
        FlatButton(
          child: const Text('忽略'),
          onPressed: () {
            setState(() {
              isShowSyncBanner = false;
            });
          },
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: body,
    );
  }

  void hiddenSnack() {
    scaffoldKey.currentState.hideCurrentSnackBar();
  }

  checkUpdate() async {
    try {
      final nextVersion = await UpdateService.checkUpdateStatus();
      if (nextVersion != null) {
        isShowUpdateBanner = true;
      }
    } catch (e) {
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
      return Column(
        children: <Widget>[
          if (isShowUpdateBanner) buildUpdateBanner(),
          if (isShowLoginBanner) buildLoginBanner(),
          if (isShowSyncBanner) buildSyncBanner(),
          Container(),
        ],
      );
    } else if (provider.loadOver && provider.isEmpty) {
      return Column(
        children: <Widget>[
          if (isShowUpdateBanner) buildUpdateBanner(),
          if (isShowLoginBanner) buildLoginBanner(),
          if (isShowSyncBanner) buildSyncBanner(),
          Expanded(
            child: ErrorPage('您没有收藏的漫画'),
          ),
        ],
      );
    } else {
      double screenWith = MediaQuery.of(context).size.width;
      double itemMaxWidth = 140;
      double radio = screenWith / itemMaxWidth;
      final double itemWidth =
          radio.floor() > 3 ? itemMaxWidth : screenWith / 3;
      final double height = (itemWidth + 20) / 13 * 15 + 40;
      var gridView = SliverGrid.count(
        crossAxisCount: radio.floor() > 3 ? radio.floor() : 3,
        childAspectRatio: itemWidth / height,
        children: provider.collectionMangaList
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
      );

      return RefreshIndicator(
          onRefresh: () => this.updateCollectedManga(),
          child: CustomScrollView(
            slivers: <Widget>[
              if (isShowUpdateBanner)
                SliverToBoxAdapter(
                  child: buildUpdateBanner(),
                ),
              if (isShowLoginBanner)
                SliverToBoxAdapter(child: buildLoginBanner()),
              if (isShowSyncBanner)
                SliverToBoxAdapter(child: buildSyncBanner()),
              gridView,
            ],
          ));
    }
  }

  startRead(Manga item) async {
    Provider.of<CollectionProvider>(context).setMangaNoUpdate(item);
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MangaInfoPage(
          infoUrl: item.infoUrl,
          sourceKey: item.sourceKey,
          coverImageBuilder: (context) => MangaCoverImage(
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
    final CollectionProvider collectionState =
        Provider.of<CollectionProvider>(context);
    final result = await collectionState.checkAndUpdateCollectManga();
    if (result != null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('收藏漫画已经更新结束'),
      ));
    }
  }

  void toLogin() async {
    LoginPageResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginPage()));
    if (result != null && result.success) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('登录成功'),
      ));
      setState(() {
        this.isShowLoginBanner = false;
        this.isShowSyncBanner = true;
      });
    }
  }
}
