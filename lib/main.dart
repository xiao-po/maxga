import 'package:flutter/material.dart';
import 'package:maxga/provider/CollectionProvider.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:maxga/route/collection/collection-page.dart';
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
        .then((v) {
      this.isInitOver = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitOver) {
      MaterialApp(
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
      ],
      child: MaterialApp(
        title: 'Maxga First Version',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CollectionPage(),
      ),
    );
  }
}
