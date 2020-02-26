
import 'package:flutter/material.dart';
import 'package:maxga/constant/icons/antd-icon.dart';

import 'base/form-item.dart';
import 'maxga-text-filed.dart';

class PasswordTextFiled extends StatefulWidget {
  final String tipText;
  final String errorText;
  final bool disabled;
  final TextEditingController controller;
  final String placeHolder;
  final Widget icon;

  PasswordTextFiled.fromItem(
      FormItem item, {
        this.icon,
        this.placeHolder = "请输入密码",
        this.tipText = "",
      })  : this.controller = item.controller,
        this.errorText = item.errorText,
        this.disabled = item.disabled;

  const PasswordTextFiled({
    Key key,
    @required this.controller,
    this.placeHolder = "请输入密码",
    this.icon,
    this.errorText,
    this.disabled = false,
    this.tipText = "",
  })  : assert(icon != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordTextFiledState();
}

class _PasswordTextFiledState extends State<PasswordTextFiled> {
  bool obscureText = true;

  changeObscureStatus() {
    setState(() {
      this.obscureText = !this.obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaxgaTextFiled(
      controller: widget.controller,
      placeHolder: widget.placeHolder,
      obscureText: obscureText,
      errorText: widget.errorText,
      disabled: widget.disabled,
      tipText: widget.tipText,
      suffixIcon: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeObscureStatus,
          child: Icon(obscureText ? AntdIcons.eye : AntdIcons.eye_close),
        ),
      ),
      icon: widget.icon ?? Icon(Icons.lock_outline),
    );
  }
}
