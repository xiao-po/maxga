import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/base/drawer/drawer-menu-item.dart';
import 'package:maxga/components/button/manga-outline-button.dart';
import 'package:maxga/constant/drawer-value.dart';
import 'package:maxga/model/user/user.dart';
import 'package:maxga/provider/public/theme-provider.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/route/android/user/base/login-page-result.dart';
import 'package:maxga/route/android/user/login-page.dart';
import 'package:maxga/route/android/user/user-detail-page.dart';
import 'package:provider/provider.dart';

import '../collection/collection-page.dart';
import '../source-viewer/source-viewer.dart';
import 'about/about-page.dart';
import 'history/history-page.dart';
import 'setting/setting-page.dart';

class MaxgaDrawer extends StatefulWidget {
  final MaxgaMenuItemType active;
  final VoidCallback loginCallback;

  const MaxgaDrawer({Key key, this.active, @required this.loginCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MaxgaDrawerState();
}

class MaxgaDrawerState extends State<MaxgaDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(primaryColor: Colors.cyan);
    final list = DrawerMenuList.map((menuItem) => ListTile(
            title: Text(menuItem.title),
            leading: Icon(menuItem.icon),
            selected: menuItem.type == widget.active,
            onTap: () => _handleMenuItemChoose(menuItem.type)))
        .toList(growable: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          MaxgaDrawerHeader(loginCallback: widget.loginCallback),
          MediaQuery.removePadding(
              context: context,
              child: Expanded(
                child: Theme(
                  data: theme,
                  child: ListView(
                    children: list,
                  ),
                ),
              )),
          ListTile(
            title: const Text('夜间模式'),
            trailing: Switch(
              value: theme.brightness == Brightness.dark,
              onChanged: (v) =>
                  Provider.of<ThemeProvider>(context).changeBrightness(),
            ),
          )
        ],
      ),
    );
  }

  _handleMenuItemChoose(MaxgaMenuItemType type) async {
    switch (type) {
      case MaxgaMenuItemType.collect:
        Navigator.pop(context);
        await AnimationDelay();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CollectionPage(),
            ));
        break;
      case MaxgaMenuItemType.mangaSourceViewer:
        Navigator.pop(context);
        await AnimationDelay();
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SourceViewerPage(),
            ));
        break;
      case MaxgaMenuItemType.history:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPage(),
            ));
        break;
      case MaxgaMenuItemType.setting:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingPage(),
            ));
        break;
      case MaxgaMenuItemType.about:
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutPage(),
            ));
        break;
    }
  }
}

const _MaxgaDrawerHeaderHeight = 120;

class MaxgaDrawerHeader extends StatelessWidget {
  const MaxgaDrawerHeader({
    Key key,
    @required this.loginCallback,
  }) : super(key: key);

  final VoidCallback loginCallback;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    var body = Consumer<UserProvider>(
      builder: (BuildContext context, UserProvider value, Widget child) {
        if (value.isLogin) {
          return MaxgaUserDrawerHeader(
              user: value.user, onLogout: () => logout(context));
        } else {
          return MaxgaLoginTipDrawerHeader();
        }
      },
    );
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight + 10, left: 20, right: 20),
      color: isDark ? Colors.grey[800] : Color(0xfff0f0f0) ,
      height: statusBarHeight + _MaxgaDrawerHeaderHeight,
      child: body,
    );
  }

  logout(BuildContext context) async {
    await AnimationDelay(Duration(milliseconds: 300));
    await showDialog(
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
  }

  onTap(BuildContext context) {
    Navigator.pop(context);
    AnimationDelay().then((v) => loginCallback());
  }
}

class MaxgaLoginTipDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("注册登录使用同步功能吧~"),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                child: FlatButton(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[300]),
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  onPressed: () {},
                  child: Text('注册',
                      style: TextStyle(
                          color: isDark ? Colors.grey[200] : theme.accentColor)),
                ),
              ),
              Container(
                height: 30,
                width: 120,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  splashColor:   Colors.black12,
                  color: theme.accentColor,
                  onPressed: () => toLogin(context),
                  child: Text('登录',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  toLogin(BuildContext context) async {
    var result = await Navigator.of(context).push<LoginPageResult>(
        MaterialPageRoute(builder: (context) => LoginPage()));
    if (result is LoginPageResult && result.success) {
      print("login success");
    }
  }
}

class MaxgaUserDrawerHeader extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const MaxgaUserDrawerHeader({Key key, @required this.user, this.onLogout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ?  Colors.grey[800] : Color(0xffE6E6E6) ,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: Colors.grey[400]),
                  ),
                  child: Icon(Icons.person_pin,
                      size: 24, color: Colors.grey[500]),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => toUserDetailPage(context),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: Colors.grey[500]),
                          ),
                          child: Icon(Icons.person,
                              size: 18, color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onLogout,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: Colors.grey[500]),
                          ),
                          child: Icon(Icons.exit_to_app,
                              size: 18, color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.username,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  toUserDetailPage(BuildContext context) async {
    await AnimationDelay();
    Navigator.pop(context);
    await AnimationDelay();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailPage(),
        ));
  }
}
