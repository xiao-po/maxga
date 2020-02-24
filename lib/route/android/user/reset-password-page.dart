import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/http/server/base/MaxgaRequestError.dart';
import 'package:maxga/http/server/base/MaxgaServerResponseStatus.dart';
import 'package:maxga/route/android/user/base/FormItem.dart';
import 'package:maxga/route/android/user/base/MaxgaValidator.dart';
import 'package:maxga/route/android/user/base/user-page-form-components.dart';
import 'package:maxga/service/user.service.dart';

import 'components/RegistryButton.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  FormItem emailFormItem =
      FormItem(validators: [MaxgaValidator.emailValidator]);

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool resetRequestSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('重置密码'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: ListView(
          children: <Widget>[
            MaxgaTextFiled.fromItem(
              emailFormItem,
              icon: Icons.email,
              tipText: "请输入你需要重置的账号关联的邮箱，然后点击重置密码链接。",
            ),
            Container(height: 20),
            if (!resetRequestSuccess) Container(
              width: double.infinity,
              height: 40,
              child: PrimaryButton(
                onPressed: resetPassword,
                content: Text(
                  '重置密码',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (resetRequestSuccess) Container(
              child: Text("密码重置邮件已经发送到你的信箱，请注意查收", style: TextStyle(
                color: Colors.green[600],
              )),
            )
          ],
        ),
      ),
    );
  }

  void resetPassword() async {
    if (emailFormItem.invalid) {
      return null;
    }
    emailFormItem.isDirty = true;
    emailFormItem.validateValue();
    if (emailFormItem.invalid) {
      return null;
    } else {
      try {
        await UserService.resetPasswordRequest(emailFormItem.value);
        setState(() {
          emailFormItem.disable();
          resetRequestSuccess = true;
        });
      } on MaxgaRequestError catch (e) {
        switch (e.status) {
          case MaxgaServerResponseStatus.TIMEOUT:
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(e.message),
            ));
            break;
          case MaxgaServerResponseStatus.RESET_EMAIL_LIMITED:
            setState(() {
              emailFormItem.setError(e.message);
            });
            break;
          case MaxgaServerResponseStatus.PARAM_ERROR:
          case MaxgaServerResponseStatus.SHOULD_LOGIN:
          case MaxgaServerResponseStatus.AUTH_PASSWORD_ERROR:
          case MaxgaServerResponseStatus.JWT_TIMEOUT:
          case MaxgaServerResponseStatus.USER_NOT_EXIST:
          case MaxgaServerResponseStatus.USERNAME_INVALID:
          case MaxgaServerResponseStatus.PASSWORD_INVALID:
          case MaxgaServerResponseStatus.EMAIL_INVALID:
          case MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE:
          case MaxgaServerResponseStatus.ANOTHER_ACTIVE_TOKEN_EXIST:
          case MaxgaServerResponseStatus.UPDATE_VALUE_EXIST:
          case MaxgaServerResponseStatus.UPDATE_VALUE_OUT_OF_DATE:
          case MaxgaServerResponseStatus.OPERATION_NOT_PERMIT:
          case MaxgaServerResponseStatus.SERVICE_FAILED:
            scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("服务器异常"),
            ));
            break;
          case MaxgaServerResponseStatus.SUCCESS:
            break;
        }
      } catch(e) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("请求失败"),
        ));
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
    emailFormItem.dispose();
  }
}
