import 'package:flutter/material.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/provider/public/collection-provider.dart';
import 'package:maxga/provider/public/history-provider.dart';
import 'package:maxga/provider/public/setting-provider.dart';
import 'package:maxga/provider/public/theme-provider.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/route/android/collection/collection-page.dart';
import 'package:maxga/route/android/source-viewer/source-viewer.dart';
import 'package:provider/provider.dart';

import 'database/database-initializr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInitOver = false;

  @override
  void initState() {
    super.initState();
    MaxgaDatabaseInitializr.initDataBase()
        .then((v) => HistoryProvider.getInstance().init())
        .then((v) => CollectionProvider.getInstance().init())
        .then((v) => SettingProvider.getInstance().init())
        .then((v) => ThemeProvider.getInstance().init())
        .then((v) => UserProvider.getInstance().init())
        .then((v) {
      this.isInitOver = true;

      print('app init over');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitOver) {
      return MaterialApp(
        title: 'Maxga First Version',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HistoryProvider.getInstance(),
        ),
        ChangeNotifierProvider(
          create: (context) => CollectionProvider.getInstance(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingProvider.getInstance(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider.getInstance(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider.getInstance(),
        ),
      ],
      child: MaxGaApp(),
    );
  }
}

class MaxGaApp extends StatelessWidget {

  const MaxGaApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SettingProvider settingProvider = Provider.of<SettingProvider>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) =>  MaterialApp(
        title: 'Maxga First Version',
        theme: themeProvider.theme,
        home: settingProvider.getItemValue(MaxgaSettingItemType.defaultIndexPage) == '0' ? CollectionPage() : SourceViewerPage(),
      ),
    );
  }
}
