import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/components/list-tile.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:provider/provider.dart';

class UserSyncTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
      title: Text('同步数据'),
      trailing: Icon(Icons.chevron_right),
      onPressed: () => this.syncData(context),
    );
  }

  syncData(BuildContext context) async {
    await AnimationDelay();
    showDialog(
        context: context, child: CircularProgressDialog(forbidCancel: true,tip: "同步中...",));
    try {
      await Future.wait([
        UserProvider.getInstance().sync(),
        AnimationDelay(),
      ]);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('同步结束'),
      ));
    }catch(e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('同步失败'),
      ));

    } finally {

      Navigator.pop(context);
    }
  }
}

class UserSyncTimeListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
      title: Text('最后同步'),
      trailing: Consumer<UserProvider>(
        builder: (context, provider, child) =>
            Text(provider.lastSyncTime != null ? DateUtils.formatTime(time: provider.lastSyncTime, template: "YYYY-MM-dd HH:mm:ss") : "暂未同步"),
      ),
    );
  }

}