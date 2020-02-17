import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/components/list-tile.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:provider/provider.dart';

class UserSyncTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaxgaListTile(
      title: Text('同步数据'),
      onPressed: () => this.syncData(context),
      training: Consumer<UserProvider>(
        builder: (context, provider, child) =>
            Text(provider?.lastSyncTime?.toIso8601String() ?? "暂未同步"),
      ),
    );
  }

  syncData(BuildContext context) async {
    await AnimationDelay();
    showDialog(
        context: context, child: CircularProgressDialog(forbidCancel: true,tip: "同步中...",));
    await Future.wait([
      UserProvider.getInstance().updateSyncTime(),
      AnimationDelay(),
    ]);
    Navigator.pop(context);
  }
}
