import 'package:flutter/material.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:maxga/route/Drawer/history/history-page.dart';
import 'package:maxga/route/index/IndexPage.dart';
import 'package:provider/provider.dart';

import 'base/setting/Setting.model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<MaxgaSettingItem>>(
          initialData: [],
          builder: (context) => SettingProvider.getInstance().stream,
        ),
        StreamProvider<List<SimpleMangaInfo>>(
          initialData: [],
          builder: (context) => HistoryProvider.getInstance().stream,
        ),
      ],
      child: MaterialApp(
        title: 'Maxga First Version',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: IndexPage(),
      ),
    );
  }
}

