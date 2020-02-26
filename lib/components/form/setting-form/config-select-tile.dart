import 'package:flutter/material.dart';

import 'list-tile.dart';

class ConfigSelectTile extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final Widget title;

  const ConfigSelectTile({Key key,@required this.active,@required this.onTap,@required this.title}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaxgaConfigListTile(
      title: title,
      trailing: active ? Icon(Icons.check, color: theme.accentColor) : null,
      onPressed: onTap,
    );
  }

}