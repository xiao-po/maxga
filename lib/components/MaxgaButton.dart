import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/readMangaStatus.repo.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/provider/public//HistoryProvider.dart';
import 'package:maxga/provider/public/SettingProvider.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:maxga/route/android/user/login-page.dart';
import 'package:maxga/route/android/user/user-detail-page.dart';
import 'package:maxga/route/ios/index/index-page.dart';
import 'package:maxga/route/android/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:maxga/service/MaxgaServer.service.dart';
import 'package:provider/provider.dart';

import '../MangaRepoPool.dart';

class MaxgaSearchButton extends StatelessWidget {
  final Color color;

  const MaxgaSearchButton({
    Key key,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: color,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
          return SearchPage();
        }));
      },
    );
  }
}

class MaxgaDebuggerDeleteCacheButton extends StatelessWidget {
  final Color color;

  const MaxgaDebuggerDeleteCacheButton({
    Key key,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: color,
      ),
      onPressed: () async {
        await Future.wait([
          MangaStorageService.clearStatus(),
          Provider.of<HistoryProvider>(context).clearHistory()
        ]);
        Scaffold.of(context).showSnackBar(SnackBar(content: const Text('删除完毕')));

      },
    );
  }
}

class MaxgaTestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.details,
      ),
      onPressed: () async {

      },
    );
  }
}

typedef OnMangaSelected = void Function(MangaSource source);

class MaxgaSourceSelectButton extends StatelessWidget {
  final OnMangaSelected onSelect;
  final _sourceList = MangaRepoPool.getInstance()?.allDataSource;

  MaxgaSourceSelectButton({Key key, @required this.onSelect}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MangaSource>(
      itemBuilder: (context) => _sourceList
          .map((el) => PopupMenuItem(
        value: el,
        child: Text(el.name),
      ))
          .toList(),
      onSelected: (value) => this.onSelect(value),
    );
  }

}
