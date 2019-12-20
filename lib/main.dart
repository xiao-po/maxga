import 'package:flutter/material.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/provider/IndexPageTypeProvider.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:maxga/route/index/IndexPage.dart';
import 'package:provider/provider.dart';

import 'base/drawer/menu-item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HistoryProvider(),
        ),
//        ChangeNotifierProvider(
//          builder: (context) => IndexPageTypeProvider(),
//        ),
        StreamProvider<MaxgaMenuItemType>(
          create: (context) => IndexPageTypeProvider.getInstance().streamController.stream,
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
        home: IndexPage(),
      ),
    );
  }
}

