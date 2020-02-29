import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/dialog/circular-progress-dialog.dart';
import 'package:maxga/components/form/base/form-item.dart';
import 'package:maxga/components/form/base/validator.dart';
import 'package:maxga/components/form/maxga-text-filed.dart';
import 'package:maxga/components/form/password-text-filed.dart';
import 'package:maxga/http/server/base/maxga-request-error.dart';
import 'package:maxga/model/user/user.dart';
import 'package:maxga/provider/public/user-provider.dart';
import 'package:maxga/route/android/user/base/login-page-result.dart';
import 'package:maxga/route/android/user/components/registry-button.dart';
import 'package:maxga/route/android/user/registry-page.dart';
import 'package:maxga/service/user.service.dart';

import 'components/reset-password-button.dart';

enum _AuthType { login, registry }

class AuthPage extends StatefulWidget {
  final initType;

  AuthPage.registry(): this.initType = _AuthType.registry;
  AuthPage(): this.initType = _AuthType.login;

  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  var type;

  bool get isLogin => type == _AuthType.login;

  @override
  void initState() {
    super.initState();
    this.type = widget.initType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var body = isLogin ? LoginPage() : RegistryPage();
    return Scaffold(
        appBar: AppBar(
          title: Text(isLogin ? '登录' : '注册'),
          actions: <Widget>[
            GestureDetector(
              onTapUp: (details) {
                setState(() {
                  type = isLogin ? _AuthType.registry : _AuthType.login;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                child: Text(isLogin ? "注册账号" : "登录账号"),
              ),
            ),
          ],
        ),
        body: body);
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 50),
      child: Column(
        children: <Widget>[
          MaxgaTextFiled.fromItem(usernameItem,
              placeHolder: "请输入用户名", icon: Icon(Icons.person)),
          PasswordTextFiled.fromItem(passwordItem),
          Container(
            alignment: Alignment.centerRight,
            child: ResetPasswordButton(),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
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
    );
  }

  void login() async {
    this.usernameItem.setDirty();
    this.usernameItem.validateValue();
    this.usernameItem.setDirty();
    this.passwordItem.validateValue();
    FocusScope.of(context).requestFocus(new FocusNode());

    if (usernameItem.invalid || passwordItem.invalid) {
      Scaffold.of(context).showSnackBar(SnackBar(
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
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("取消登录"),
          ));
        }
        var user = result[0] as User;
        await UserProvider.getInstance().setLoginStatus(user);
        Navigator.pop(context);
        Navigator.pop(context, AuthPageResult(true));
      } catch (e) {
        Navigator.pop(context);
        if (e is MaxgaRequestError) {
          Scaffold.of(context).showSnackBar(SnackBar(
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
    return PrimaryButton(
      onPressed: onPressed,
      content: Text(
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
        side: BorderSide(color: Colors.grey[300]),
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
