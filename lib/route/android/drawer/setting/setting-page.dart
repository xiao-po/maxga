import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/provider/public/SettingProvider.dart';
import 'package:provider/provider.dart';

import 'components/setting-list-lile.dart';


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
    List<MaxgaSettingItem> settings =
        Provider.of<SettingProvider>(context).itemList;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('设置'),
      ),
      body: ListView.builder(
        itemCount: settings.length,
        itemBuilder: (context, index) =>
            SettingListTile(setting: settings[index]),
      ),
    );
  }
}
