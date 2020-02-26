import 'package:flutter/material.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/components/base/zero-divider.dart';

import 'list-tile.dart';
import 'config-select-tile.dart';

class SelectConfigPage<T> extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final T active;
  final List<SelectOption<T>> items;
  final Widget tip;
  final ValueChanged<SelectOption<T>> onSelect;

  const SelectConfigPage({Key key,
    @required this.title,
    this.actions,
    @required this.active,
    @required this.items,
    this.tip,
    @required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final option = items[i];
      children.add(ConfigSelectTile(
        title: Text(option.title),
        active: active == option.value,
        onTap: () => onSelect(option),
      ));
      if ((i + 1) < items.length) {
        children.add(ZeroDivider());
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: title,
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 30),
            child: ListView(
              children: <Widget>[
                Container(
                    decoration: ConfigListBoxDecoration(theme),
                    child: Column(children: children)),
                if (tip != null)
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: tip,
                  )
              ],
            )));
  }
}
