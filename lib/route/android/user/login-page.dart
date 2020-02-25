import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/http/server/base/MaxgaRequestError.dart';
import 'package:maxga/model/user/User.dart';
import 'package:maxga/provider/public/UserProvider.dart';
import 'package:maxga/route/android/user/base/LoginPageResult.dart';
import 'package:maxga/route/android/user/base/MaxgaValidator.dart';
import 'package:maxga/route/android/user/base/RegistryPageResult.dart';
import 'package:maxga/route/android/user/registry-page.dart';
import 'package:maxga/service/user.service.dart';

import 'base/FormItem.dart';
import 'base/user-page-form-components.dart';
import 'components/reset-password-button.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final usernameItem = FormItem(validators: [MaxgaValidator.emptyValidator]);
  final passwordItem = FormItem(validators: [MaxgaValidator.emptyValidator]);

  @override
  void initState() {
    super.initState();
    this.usernameItem.addListener(() => setState(() {}));
    this.passwordItem.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('登录'),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 30),
          child: Column(
            children: <Widget>[
              Hero(
                tag: 'username',
                child: MaxgaTextFiled.fromItem(usernameItem,
                    placeHolder: "请输入用户名", icon: Icons.person),
              ),
              MaxgaTextFiled.fromItem(passwordItem,
                  obscureText: true,
                  icon: Icons.lock_outline, placeHolder: "请输入密码"),
              Container(
                alignment: Alignment.centerRight,
                child: ResetPasswordButton(),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      height: 40,
                      child: _RegistryButton(
                        onPressed: () => this.goRegistryPage(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      height: 40,
                      child: _LoginButton(
                        onPressed: login,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  goRegistryPage() async {
    setState(() {
      usernameItem.clearError();
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    RegistryPageResult result = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => RegistryPage(username: usernameItem.value)));
    if (result is RegistryPageResult && result.success) {
      this.usernameItem.controller.text = result.username;
      scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: Text('注册成功'),
      ));
    }
  }

  void login() async {
    this.usernameItem.isDirty = true;
    this.usernameItem.validateValue();
    this.passwordItem.isDirty = true;
    this.passwordItem.validateValue();
    FocusScope.of(context).requestFocus(new FocusNode());

    if (usernameItem.invalid || passwordItem.invalid) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(usernameItem.errorText ?? passwordItem.errorText),
      ));
    } else {
      try {
        FocusScope.of(context).requestFocus(new FocusNode());
        var result = await Future.any([
          Future.wait([
            UserService.login(UserQuery(
              usernameItem.value.trim(),
              passwordItem.value.trim(),
            )),
            Future.delayed(Duration(milliseconds: 300))
          ]),
          showDialog(context: context, child: CircularProgressDialog())
        ]);
        if (result == null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("取消登录"),
          ));
        }
        Navigator.pop(context);
        var user = result[0] as User;
        print('token is ${user?.token ?? ''}');
        UserProvider.getInstance().setLoginStatus(user);
        Navigator.pop(context, LoginPageResult(true));
      } catch (e) {
        Navigator.pop(context);
        if (e is MaxgaRequestError) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(e.message),
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    this.usernameItem.dispose();
    this.passwordItem.dispose();
  }
}


class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({
    Key key,
    VoidCallback onPressed,
  })  : this.onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
      ),
      color: theme.accentColor,
      onPressed: onPressed,
      child: Text(
        '登录',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _RegistryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RegistryButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    return FlatButton(
      color: isDark ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
        side: BorderSide(color:  Colors.grey[300]),
      ),
      onPressed: onPressed,
      child: Text(
        '注册',
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? Colors.grey[200] : theme.accentColor),
      ),
    );
  }
}
