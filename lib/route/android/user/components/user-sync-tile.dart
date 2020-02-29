import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/dialog/circular-progress-dialog.dart';
import 'package:maxga/components/form/setting-form/list-tile.dart';
import 'package:maxga/http/server/base/maxga-request-error.dart';
import 'package:maxga/http/server/base/maxga-server-response-status.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/utils/date-utils.dart';
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
    } on MaxgaRequestError catch(e) {
      switch(e. status) {
        case MaxgaServerResponseStatus.TOKEN_INVALID:
        case MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('登录信息已经过期，请重新登录继续操作'),
          ));
          break;
        default:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('同步失败'),
          ));
      }
    } catch(e) {
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