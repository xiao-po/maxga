import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/setting/Setting.model.dart';
import 'package:maxga/provider/SettingProvider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  @override
  void initState() {
    // TODO: implement initState
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
        children: settings.map((item) => buildSettingWidgetByItem(item)).toList(growable: false),
      ),
    );
  }

  Widget buildSettingWidgetByItem(MaxgaSettingItem item) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item?.value ?? '') ?? null,
      trailing: Icon(Icons.arrow_forward_ios, size: 14,),
      onTap: () {
        SettingProvider.getInstance().modifySetting(item, '2');
      },
    );
  }

}
