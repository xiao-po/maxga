import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              '应用设置',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
          ListTile(
            title: Text('测试'),
            subtitle: Text('测试'),
            trailing: Icon(Icons.arrow_forward_ios, size: 14,),
            onTap: () {

            },
          )
        ],
      ),
    );
  }
}
