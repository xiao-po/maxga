
import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:provider/provider.dart';

import 'SettingListTile.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<MaxgaSettingItem> settings = Provider.of<List<MaxgaSettingItem>>(context);
    print(settings);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('设置'),
      ),
      body: ListView(
        children: settings.map((item) => SettingListTile(setting: item)).toList(growable: false),
      ),
    );
  }

}
