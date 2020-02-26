import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/database/read-manga-status.repo.dart';
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

import '../../MangaRepoPool.dart';

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

