import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/form/base/form-item.dart';
import 'package:maxga/components/form/base/validator.dart';
import 'package:maxga/components/form/maxga-text-filed.dart';
import 'package:maxga/components/form/password-text-filed.dart';

import 'components/registry-button.dart';

class ModifyPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModifyPasswordPageState();
}

class _ModifyPasswordPageState extends State<ModifyPasswordPage> {
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
      print(
          'password is ${this.newPasswordItem.value}, repassword is ${this.newRePasswordItem.value}');
      return "两次输入密码不一致";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () {},
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
}
