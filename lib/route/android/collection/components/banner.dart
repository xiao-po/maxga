
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:maxga/route/android/user/base/LoginPageResult.dart';
import 'package:maxga/route/android/user/login-page.dart';

class SyncBanner extends StatelessWidget {
  final VoidCallback onSyncSuccess;
  final VoidCallback onIgnore;

  const SyncBanner(
      {Key key, @required this.onSyncSuccess, @required this.onIgnore})
      : assert(onIgnore != null),
        assert(onSyncSuccess != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var body = MaterialBanner(
      content: const Text('是否立即同步的收藏和阅读记录？'),
      leading: const CircleAvatar(child: Icon(Icons.sync)),
      actions: <Widget>[
        FlatButton(
          child: const Text('同步'),
          onPressed: () async {
            showDialog(
                context: context,
                child: CircularProgressDialog(forbidCancel: false, tip: "同步中"));
            await Future.wait([
              UserProvider.getInstance().sync(),
              AnimationDelay(),
            ]);
            Navigator.pop(context);
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('同步完成'),
            ));
            onSyncSuccess();
          },
        ),
        FlatButton(
          child: const Text('忽略'),
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
            toLogin(context);
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

  void toLogin(BuildContext context) async {
    LoginPageResult result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginPage()));
    if (result != null && result.success) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('登录成功'),
      ));
      if (onSuccess != null) {
        onSuccess();
      }
    }
  }
}

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    var body = MaterialBanner(
      content: const Text('有新版本更新, 点击查看'),
      leading: const CircleAvatar(child: Icon(Icons.arrow_upward)),
      actions: <Widget>[
        FlatButton(
          child: const Text('查看'),
          onPressed: () => updateAction(true),
        ),
        FlatButton(
          child: const Text('忽略'),
          onPressed: () => updateAction(true),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: 10),

      child: body,
    );
  }

  updateAction(bool canUpdate) {
    if (canUpdate) {
    } else {}
    if (onPressed != null) {
      onPressed();
    }
  }
}
