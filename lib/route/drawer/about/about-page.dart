import 'dart:io';


import 'package:flutter/material.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/service/UpdateService.dart';
import 'package:url_launcher/url_launcher.dart';

const RepoUrl = 'https://github.com/xiao-po/maxga';

enum CheckUpdateStatus {
  none,
  loading,
  shouldUpdate,
  notUpdate,
  error,
}

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  MaxgaReleaseInfo nextVersion;
  String currentVersion;
  CheckUpdateStatus checkUpdateLoading = CheckUpdateStatus.none;

  @override
  void initState() {
    super.initState();
    UpdateService.getCurrentVersion().then((v) {
      currentVersion = v;
      setState(() { });
    });
    if (Platform.isAndroid) {
      checkUpdateStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> list = [];
    if (Platform.isAndroid) {
      list.add(ListTile(
        title: const Text('检查新版本'),
        trailing: buildListTileTrailing(checkUpdateLoading),
        onTap: () => handleUpdateListTileTapEvent(),
      ));
    }
    list.add(ListTile(
      title: const Text('源代码仓库'),
      subtitle: const Text(RepoUrl),
      onTap: () => openRepoUrl(RepoUrl),
    ));
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: BackButton(),
          title: const Text('关于'),
        ),
        body: Column(
          children: <Widget>[
            buildApplicationAndVersionIntro(),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                itemBuilder: (context, index) => list[index],
                separatorBuilder: (context, index) {
                  return Divider();
                },
              ),
            )
          ],
        ));
  }

  handleUpdateListTileTapEvent() {
    switch(checkUpdateLoading) {
      case CheckUpdateStatus.notUpdate:
      case CheckUpdateStatus.none:
      case CheckUpdateStatus.loading:
        break;
      case CheckUpdateStatus.shouldUpdate:
        openRepoUrl(nextVersion.url);
        break;
      case CheckUpdateStatus.error:
        checkUpdateStatus();
        break;
    }
  }

  Widget buildListTileTrailing(CheckUpdateStatus checkUpdateLoading) {
    const trailingTextStyle = TextStyle(color: Colors.black26);
    switch (checkUpdateLoading) {
      case CheckUpdateStatus.loading:
        return buildListTileIndicator();
      case CheckUpdateStatus.shouldUpdate:
        return Text('有更新', style: trailingTextStyle);
      case CheckUpdateStatus.notUpdate:
        return Text('已经是最新版本', style: trailingTextStyle);
      case CheckUpdateStatus.none:
        return null;
      case CheckUpdateStatus.error:
        return Text('网络出错', style: trailingTextStyle);
      default: {
        throw Error();
      }
    }
  }

  Widget buildListTileIndicator() => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
      );

  Widget buildApplicationAndVersionIntro() {
    return Container(
      height: 200,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffefefef)))),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text('MaxGa',
              style: TextStyle(fontSize: 40, color: Colors.cyan)),
          Text('version: $currentVersion', style: TextStyle(color: Colors.black38))
        ],
      ),
    );
  }

  openRepoUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  checkUpdateStatus() async {
    this.checkUpdateLoading = CheckUpdateStatus.loading;
    setState(() {});
    final nextVersion = await UpdateService.checkUpdateStatusWithoutIgnore();
    if (nextVersion != null) {
      this.checkUpdateLoading = CheckUpdateStatus.shouldUpdate;
    } else {
      this.checkUpdateLoading = CheckUpdateStatus.notUpdate;
    }
    this.nextVersion = nextVersion;
    if (mounted) {
      setState(() {});
    }
  }

  void openUpdateSnackBar(MaxgaReleaseInfo nextVersion) {
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
                  openRepoUrl(nextVersion.url);
                  scaffoldKey.currentState.hideCurrentSnackBar();
                },
              ),
              GestureDetector(
                child: Padding(
                  padding: buttonPadding,
                  child: Text('忽略', style: buttonTextStyle),
                ),
                onTap: () {
                  scaffoldKey.currentState.hideCurrentSnackBar();
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
