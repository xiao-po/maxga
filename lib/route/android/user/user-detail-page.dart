import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/list-tile.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:provider/provider.dart';

import 'components/user-sync-tile.dart';

class UserDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('用户信息'),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: ListView(
            children: <Widget>[
              Container(
                decoration: ConfigListBoxDecoration(),
                child: Consumer<UserProvider>(
                  builder: (context, provider, child) => Column(
                    children: <Widget>[
                      MaxgaListTile(
                          title: Text("用户名"),
                          training: Text(provider.user?.username ?? "")),
                      Divider(height: 1, color: Colors.grey[300]),
                      MaxgaListTile(
                          onPressed: () {},
                          title: Text("邮箱"),
                          training: Text(provider.user?.email ?? "")),
                      Divider(height: 1, color: Colors.grey[300]),
                      MaxgaListTile(
                          onPressed: () {},
                          title: Text("注册时间"),
                          training:
                              Text(provider.user?.createTime?.toIso8601String() ?? ""))
                    ],
                  ),
                ),
              ),
              Container(height: 30),
              Container(
                width: double.infinity,
                decoration: ConfigListBoxDecoration(),
                child: UserSyncTile(),
              ),
              Container(height: 30),
              Container(
                width: double.infinity,
                decoration: ConfigListBoxDecoration(),
                child: _LogoutListTile(),
              )
            ],
          ),
        ));
  }
}

class _LogoutListTile extends StatelessWidget {
  const _LogoutListTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => logout(context),
        child: Container(
          padding:
              const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 15),
          child: Text(
            '退出登录',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void logout(BuildContext context) async {
    bool result = await showDialog(
        context: context,
        child: AlertDialog(
          title: Text("是否退出登录"),
          content: Text("退出登录并不会清空现在 app 的数据，但是会失去和账号同步数据的功能"),
          actions: <Widget>[
            FlatButton(
              onPressed: () async {
                await UserProvider.getInstance().logout();
                Navigator.pop(context, true);
              },
              child: const Text('退出'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            )
          ],
        ));
    if (result != null) {
      Navigator.pop(context);
    }
  }
}



