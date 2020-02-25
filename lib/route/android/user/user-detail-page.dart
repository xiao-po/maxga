import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/setting/SettingValue.dart';
import 'package:maxga/components/base/ZeroDivider.dart';
import 'package:maxga/components/list-tile.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:maxga/route/android/user/modify-password-page.dart';
import 'package:provider/provider.dart';

import 'components/user-sync-tile.dart';

const List<SelectOption<int>> SyncIntervalOptions = [
  SelectOption(title: '手动更新', value: 0),
  SelectOption(title: '1 天', value: 1),
  SelectOption(title: '2 天', value: 2),
  SelectOption(title: '3 天', value: 3),
  SelectOption(title: '4 天', value: 4),
  SelectOption(title: '5 天', value: 5),
  SelectOption(title: '6 天', value: 6),
  SelectOption(title: '一周', value: 7),
];

class UserDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('用户信息'),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: ListView(
            children: <Widget>[
              Container(
                decoration: ConfigListBoxDecoration(theme),
                child: Consumer<UserProvider>(
                  builder: (context, provider, child) => Column(
                    children: <Widget>[
                      MaxgaConfigListTile(
                          title: Text("用户名"),
                          trailing: Text(provider.user?.username ?? "")),
                      ZeroDivider(),
                      MaxgaConfigListTile(
                          title: Text("邮箱"),
                          trailing: Text(provider.user?.email ?? "")),
                      ZeroDivider(),
                      MaxgaConfigListTile(
                        title: Text("注册时间"),
                        trailing: Text(provider.user != null
                            ? DateUtils.formatTime(
                                time: provider.user.createTime,
                                template: "YYYY-MM-dd")
                            : ""),
                      ),
                      ZeroDivider(),
                      MaxgaConfigListTile(
                          onPressed: toModifyPassword,
                          title: Text("修改密码"),
                          trailing: Icon(Icons.chevron_right)),
                    ],
                  ),
                ),
              ),
              Container(height: 30),
              Container(
                width: double.infinity,
                decoration: ConfigListBoxDecoration(theme),
                child: Column(
                  children: <Widget>[
                    UserSyncTimeListTile(),
                    ZeroDivider(),
                    UserSyncIntervalTile(),
                    ZeroDivider(),
                    UserSyncTile()
                  ],
                ),
              ),
              Container(height: 30),
              Container(
                width: double.infinity,
                decoration: ConfigListBoxDecoration(theme),
                child: _LogoutListTile(),
              )
            ],
          ),
        ));
  }

  void toModifyPassword() async {
    await AnimationDelay();
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ModifyPasswordPage()));
  }
}

class UserSyncIntervalTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaxgaConfigListTile(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SyncIntervalConfigPage(),
          ));
        },
        title: Text("提醒同步周期"),
        trailing: Consumer<UserProvider>(
            builder: (context, provider, child) => RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: SyncIntervalOptions.firstWhere((option) => option.value == provider.syncInterval).title,
                        style: TextStyle(color: Colors.grey[500])),
                    const WidgetSpan(child: Icon(Icons.keyboard_arrow_right)),
                  ]),
                )));
  }
}


class SyncIntervalConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("提醒自动同步周期"),
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 30),
          child: ListView(children: <Widget>[
            Container(
                decoration: ConfigListBoxDecoration(theme),
                child:
                    Consumer<UserProvider>(builder: (context, provider, child) {
                  var children = <Widget>[];
                  for (var i = 0; i < SyncIntervalOptions.length; i++) {
                    final option = SyncIntervalOptions[i];
                    children.add(MaxgaConfigSelectTile(
                      title: Text(option.title),
                      active: provider.syncInterval == option.value,
                      onTap: () {
                        provider.setSyncInterval(option.value);
                      },
                    ));
                    if ((i + 1) < SyncIntervalOptions.length) {
                      children.add(ZeroDivider());
                    }
                  }
                  return Column(
                    children: children,
                  );
                }))
          ])),
    );
  }
}

class _LogoutListTile extends StatelessWidget {
  const _LogoutListTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    var textColor = isDark ? Colors.grey[400] : Colors.grey[700];
    return Material(
      color: isDark ? Colors.grey[800] : null,
      child: InkWell(
        onTap: () => logout(context),
        child: Container(
          padding:
              const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 15),
          child: Text(
            '退出登录',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  void logout(BuildContext context) async {
    await AnimationDelay();
    bool result = await showDialog(
        context: context,
        child: AlertDialog(
          title: Text("是否退出登录"),
          content: Text("退出登录并不会清空现在 app 的数据，但是会失去和账号同步数据的功能"),
          actions: <Widget>[
            FlatButton(
              onPressed: () async {
                await AnimationDelay();
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            FlatButton(
              onPressed: () async {
                await Future.wait(
                    [UserProvider.getInstance().logout(), AnimationDelay()]);
                Navigator.pop(context, true);
              },
              child: const Text('退出'),
            ),
          ],
        ));
    if (result != null) {
      Navigator.pop(context);
    }
  }
}
