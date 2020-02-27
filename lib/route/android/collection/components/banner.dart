
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/dialog/circular-progress-dialog.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/route/android/user/base/login-page-result.dart';
import 'package:maxga/route/android/user/login-page.dart';
import 'package:provider/provider.dart';

class SyncBanner extends StatelessWidget {
  final VoidCallback onSuccess;
  final VoidCallback onIgnore;

  const SyncBanner(
      {Key key, @required this.onSuccess, @required this.onIgnore})
      : assert(onIgnore != null),
        assert(onSuccess != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    var tipText = const Text('是否立即同步的收藏和阅读记录？');
    if (userProvider.lastRemindSyncTime != null) {
      tipText =
          Text('已经超过 ${userProvider.syncInterval} 天未同步数据，是否立即同步的收藏和阅读记录？');
    }
    var body = MaterialBanner(
      content: tipText,
      leading: const CircleAvatar(child: Icon(Icons.sync)),
      actions: <Widget>[
        FlatButton(
          child: const Text('同步'),
          onPressed: onSuccess,
        ),
        FlatButton(
          child: const Text('下次提醒'),
          onPressed: onIgnore,
        ),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: body,
    );
  }
}

class LoginBanner extends StatelessWidget {
  final VoidCallback onSuccess;
  final VoidCallback onIgnore;

  const LoginBanner(
      {Key key, @required this.onSuccess, @required this.onIgnore})
      : assert(onSuccess != null),
        assert(onIgnore != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var body = MaterialBanner(
      content: const Text('登录后即可享受同步多设备间的阅读数据，不丢失阅读记录'),
      leading: const CircleAvatar(child: Icon(Icons.person_pin)),
      actions: <Widget>[
        FlatButton(
          child: const Text('登录'),
          onPressed: () async {
            await AnimationDelay();
            onSuccess();
          },
        ),
        FlatButton(
          child: const Text('忽略'),
          onPressed: () async {
            await AnimationDelay();
            if (onIgnore != null) {
              onIgnore();
            }
          },
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: body,
    );
  }

}

class UpdateBanner extends StatelessWidget {


  const UpdateBanner({
    Key key,
    @required this.onUpdate,
    @required this.onDismiss,
  }) : super(key: key);
  final VoidCallback onDismiss;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    var body = MaterialBanner(
      content: const Text('有新版本更新, 点击查看'),
      leading: const CircleAvatar(child: Icon(Icons.arrow_upward)),
      actions: <Widget>[
        FlatButton(
          child: const Text('查看'),
          onPressed: onUpdate,
        ),
        FlatButton(
          child: const Text('忽略'),
          onPressed: onDismiss,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: 10),

      child: body,
    );
  }

}
