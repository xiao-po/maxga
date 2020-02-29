import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/form/base/form-item.dart';
import 'package:maxga/components/form/base/validator.dart';
import 'package:maxga/components/form/password-text-filed.dart';
import 'package:maxga/http/server/base/maxga-request-error.dart';
import 'package:maxga/http/server/base/maxga-server-response-status.dart';
import 'package:maxga/service/user.service.dart';

import 'components/registry-button.dart';

class ModifyPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModifyPasswordPageState();
}

class _ModifyPasswordPageState extends State<ModifyPasswordPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  FormItem oldPasswordItem;
  FormItem newPasswordItem;
  FormItem newRePasswordItem;

  List<FormItem> get allItem => [
        oldPasswordItem,
        newPasswordItem,
        newRePasswordItem,
      ];

  @override
  void initState() {
    super.initState();
    oldPasswordItem = FormItem(validators: [
      MaxgaValidator.emptyValidator,
      MaxgaValidator.passwordLengthValidator,
      MaxgaValidator.checkSpaceExist,
    ]);
    newPasswordItem = FormItem(validators: [
      MaxgaValidator.emptyValidator,
      MaxgaValidator.passwordLengthValidator,
      MaxgaValidator.checkSpaceExist,
      _passwordConfirmValidator,
    ]);
    newRePasswordItem = FormItem(validators: [
      MaxgaValidator.emptyValidator,
      MaxgaValidator.passwordLengthValidator,
      MaxgaValidator.checkSpaceExist,
      _passwordConfirmValidator,
    ]);
    newPasswordItem.addInputListener(_passwordChange);
    newRePasswordItem.addInputListener(_passwordChange);

    for (final item in this.allItem) {
      item.addListener(() {
        setState(() {});
      });
    }
  }

  _passwordChange() {
    this.newPasswordItem.validateValue();
    this.newRePasswordItem.validateValue();
  }

  String _passwordConfirmValidator(v) {
    if (this.newPasswordItem.value != "" &&
        this.newRePasswordItem.value != "" &&
        this.newPasswordItem.value != this.newRePasswordItem.value) {
      return "两次输入密码不一致";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("修改密码"),
      ),
      body: Padding(
        padding: EdgeInsets.only(right: 10, left: 10, top: 20),
        child: ListView(
          children: <Widget>[
            PasswordTextFiled.fromItem(
              oldPasswordItem,
              placeHolder: "请输入原密码",
            ),
            PasswordTextFiled.fromItem(
              newPasswordItem,
              icon: Icon(Icons.lock),
              placeHolder: "请输入新密码",
              tipText: "密码不得少于 6 位，不能多于 20 位",
            ),
            PasswordTextFiled.fromItem(
              newRePasswordItem,
              icon: Icon(Icons.lock),
              placeHolder: "请再次输入新密码",
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Container(
                width: double.infinity,
                height: 40,
                child: PrimaryButton(
                  onPressed: changePassword,
                  content: Text(
                    '修改密码',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final item in this.allItem) {
      item.dispose();
    }
  }

  void changePassword() async {
    var errorText = _validateForm();
    if (errorText != null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(errorText),
      ));
      return null;
    }
    var oldPassword = oldPasswordItem.value;
    var newPassword = newPasswordItem.value;
    if (oldPassword == newPassword) {
      oldPasswordItem.setError("新密码和旧密码禁止一样");
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: const Text("新密码和旧密码禁止一样"),
      ));
      return null;
    }
    try {
      await UserService.changePassword(oldPassword, newPassword);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('修改成功'),
      ));
      allItem.forEach((item) => item.clear());
    } on MaxgaRequestError catch (e) {
      switch (e.status) {
        case MaxgaServerResponseStatus.PASSWORD_INVALID:
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(e.message),
          ));
          oldPasswordItem.setError(e.message);
          break;
        case MaxgaServerResponseStatus.TOKEN_INVALID:
        case MaxgaServerResponseStatus.ACTIVE_TOKEN_OUT_OF_DATE:
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('登录信息已经过期，请重新登录继续操作'),
          ));
          break;
        default:
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('修改失败'),
          ));
      }
    } catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('修改失败'),
      ));
    }
  }

  _validateForm() {
    var errorText;
    allItem.forEach((item) {
      item.setDirty();
      item.validateValue();
    });
    for (var i = 0; i < allItem.length; i++) {
      var item = allItem[i];
      if (item.invalid) {
        errorText = item.errorText;
      }
    }
    return errorText;
  }
}
