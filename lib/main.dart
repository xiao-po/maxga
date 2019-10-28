import 'package:flutter/material.dart';
import 'package:maxga/Application.dart';
import 'package:maxga/route/index/IndexPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maxga First Version',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IndexPage(),
    );
  }
}

