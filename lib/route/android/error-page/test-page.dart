import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/clipper/TriangleClipper.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ClipTriangle(
        clip: TriangleClip.topLeft,
        child: Container(
          height: 100,
          width: 100,
          color: Colors.lightGreen,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
