
import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {

  final String name = '设置';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.name),
      ),
      body: ListView(
        children: <Widget>[],
      ),
    );
  }
}


