import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/circular-progress-dialog.dart';
import 'package:maxga/http/server/base/MaxgaRequestError.dart';
import 'package:maxga/http/server/base/MaxgaServerResponseStatus.dart';
import 'package:maxga/model/user/query/user-registry-query.dart';
import 'package:maxga/route/android/user/base/MaxgaValidator.dart';
import 'package:maxga/service/user.service.dart';

import 'base/FormItem.dart';
import 'base/RegistryPageResult.dart';
import 'base/user-page-form-components.dart';
import 'components/RegistryButton.dart';

class RegistryForm {
  final FormItem user;
  final FormItem password;
  final FormItem rePassword;
  final FormItem email;
  final VoidCallback onChange;

  List<FormItem> get allItem => [
        user,
        email,
        password,
        rePassword,
      ];

  bool get hasError =>
      user.invalid || password.invalid || rePassword.invalid || email.invalid;

  String get errorText {
    if (user.invalid) {
      return user.errorText;
    } else if (password.invalid) {
      return password.errorText;
    } else if (rePassword.invalid) {
      return rePassword.errorText;
    } else if (email.invalid) {
      return email.errorText;
    } else {
      return null;
    }
  }

  get hasEmpty =>
      user.isEmpty || password.isEmpty || rePassword.isEmpty || email.isEmpty;

  RegistryForm(
      {FormItem user,
      FormItem password,
      FormItem rePassword,
      FormItem email,
      String username,
      this.onChange})
      : this.user = user ??
            FormItem(text: username ?? "", validators: [
              MaxgaValidator.checkSpaceExist,
              MaxgaValidator.emptyValidator
            ]),
        this.password = password ??
            FormItem(validators: [
              MaxgaValidator.emptyValidator,
              MaxgaValidator.passwordLengthValidator,
              MaxgaValidator.checkSpaceExist,
            ]),
        this.rePassword = rePassword ??
            FormItem(validators: [
              MaxgaValidator.emptyValidator,
              MaxgaValidator.checkSpaceExist
            ]),
        this.email = email ??
            FormItem(validators: [
              MaxgaValidator.emptyValidator,
              MaxgaValidator.emailValidator
            ]) {
    this.rePassword.controller.addListener(_passwordChange);
    this.password.controller.addListener(_passwordChange);
    this.password.addValidator(_passwordConfirmValidator);
    this.rePassword.addValidator(_passwordConfirmValidator);
    for (var value in this.allItem) {
      value.addListener(onChange);
    }
  }

  _passwordChange() {
    this.password.validateValue();
    this.rePassword.validateValue();
  }

  String _passwordConfirmValidator(v) {
    if (this.password.value != "" &&
        this.rePassword.value != "" &&
        this.password.value != this.rePassword.value) {
      print(
          'password is ${this.password.value}, repassword is ${this.rePassword.value}');
      return "两次输入密码不一致";
    } else {
      return null;
    }
  }

  UserRegistryQuery get value => UserRegistryQuery(
        user.value.trim(),
        password.value.trim(),
        email.value,
      );

  void setDirtyAndValidate() {
    for (var value in this.allItem) {
      value.isDirty = true;
      value.validateValue();
    }
  }

  dispose() {
    this.user.dispose();
    this.rePassword.dispose();
    this.password.dispose();
    this.email.dispose();
  }
}

class RegistryPage extends StatefulWidget {
  final String username;

  const RegistryPage({Key key, this.username = ""}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegistryPageState();
}

class _RegistryPageState extends State<RegistryPage> {
  RegistryForm form;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    form = RegistryForm(
        username: widget.username, onChange: () => this.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Container(
        padding: EdgeInsets.only(right: 10, left: 10, top: 30),
        child: ListView(
          children: <Widget>[
            Hero(
              tag: 'username',
              child: MaxgaTextFiled.fromItem(
                form.user,
                placeHolder: "请输入用户名",
                icon: Icons.person,
              ),
            ),
            MaxgaTextFiled.fromItem(
              form.email,
              icon: Icons.email,
              placeHolder: "请输入邮箱地址",
              tipText: "例如 : adc123@qq.com",
            ),
            MaxgaTextFiled.fromItem(
              form.password,
              icon: Icons.lock_outline,
              placeHolder: "请输入密码",
              obscureText: true,
              tipText: "密码不得少于 6 位，不能多于 20 位",
            ),
            MaxgaTextFiled.fromItem(form.rePassword,
                obscureText: true,
                placeHolder: "请再次输入密码",
                icon: Icons.lock_outline),
            Container(
              width: double.infinity,
              height: 40,
              child: PrimaryButton(
                onPressed: registry,
                content: Text(
                  '注册',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void registry() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (form.hasError) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('注册信息存在错误'),
      ));
      return;
    }
    form.setDirtyAndValidate();
    if (form.hasError) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(form.errorText),
      ));
    } else {
      var query = form.value;
      showDialog(
          context: context,
          builder: (context) => CircularProgressDialog(forbidCancel: true));

      try {
        await UserService.registry(query);
        Navigator.pop(context);
        await AnimationDelay();
        Navigator.pop(context, RegistryPageResult(true, query.username));
      } on MaxgaRequestError catch (e) {
        Navigator.of(context).pop();
        switch (e.status) {
          case MaxgaServerResponseStatus.USERNAME_INVALID:
            setState(() {
              form.user.setError(e.message);
            });
            break;
          case MaxgaServerResponseStatus.SERVICE_FAILED:
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('服务器异常'),
            ));
            break;
          case MaxgaServerResponseStatus.PASSWORD_INVALID:
            setState(() {
              form.password.setError(e.message);
            });
            break;
          case MaxgaServerResponseStatus.EMAIL_INVALID:
            setState(() {
              form.email.setError(e.message);
            });
            break;

          case MaxgaServerResponseStatus.SUCCESS:
          case MaxgaServerResponseStatus.TIMEOUT:
          case MaxgaServerResponseStatus.PARAM_ERROR:
          case MaxgaServerResponseStatus.SHOULD_LOGIN:
          case MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR:
          case MaxgaServerResponseStatus.USER_NOT_EXIST:
          case MaxgaServerResponseStatus.JWT_TIMEOUT:
          case MaxgaServerResponseStatus.UPDATE_VALUE_EXIST:
          case MaxgaServerResponseStatus.UPDATE_VALUE_OUT_OF_DATE:
          case MaxgaServerResponseStatus.OPERATION_NOT_PERMIT:
          case MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE:
          case MaxgaServerResponseStatus.ANOTHER_ACTIVE_TOKEN_EXIST:
          case MaxgaServerResponseStatus.RESET_EMAIL_LIMITED:
            break;
        }
      } catch (e) {
        Navigator.of(context).pop();
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('服务器异常'),
        ));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    form.dispose();
  }
}
