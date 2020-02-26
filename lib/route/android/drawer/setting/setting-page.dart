import 'package:flutter/material.dart';
import 'package:maxga/components/base/ZeroDivider.dart';
import 'package:maxga/components/form/setting-form/list-tile.dart';
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
    var groups = Provider.of<SettingProvider>(context).itemList;
    ThemeData theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: const Text('设置'),
        ),
        body: ListView(
          children: groups
              .map((group) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 20, top: 20, bottom: 15),
                        child: Text(group.title, style: TextStyle(color: Colors.grey[600]),),
                      ),
                      Container(
                        decoration: ConfigListBoxDecoration(theme),
                        child: Column(
                          children: buildGroupOptions(group),
                        ),
                      ),
                    ],
                  ))
              .toList(growable: false),
        ));
  }

  List<Widget> buildGroupOptions(SettingGroup group) {
    List<Widget> children = [];
    for (var i = 0; i < group.items.length; i++) {
      children.add(SettingListTile(group.items[i]));
      if ((i + 1) < group.items.length) {
        children.add(ZeroDivider());
      }
    }
    return children;
  }
}
