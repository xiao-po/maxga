import 'package:flutter/material.dart';

import 'FormItem.dart';

class UsernameTextFiled extends StatelessWidget {
  final String errorText;

  const UsernameTextFiled({
    Key key,
    this.errorText,
    @required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return MaxgaTextFiled(
      controller: controller,
      placeHolder: "账号",
      icon: Icons.person,
    );
  }
}

class PasswordTextFiled extends StatelessWidget {
  final String errorText;

  const PasswordTextFiled({
    Key key,
    this.errorText,
    @required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return MaxgaTextFiled(
      controller: controller,
      placeHolder: "密码",
      obscureText: true,
      icon: Icons.lock_outline,
    );
  }
}

class MaxgaTextFiled extends StatelessWidget {
  MaxgaTextFiled.fromItem(
    FormItem item, {
    this.obscureText = false,
    this.icon,
    this.placeHolder = "请输入",
    this.tipText = "",
  }) : this.controller = item.controller, this.errorText = item.errorText;

  const MaxgaTextFiled({
    Key key,
    @required this.controller,
    this.placeHolder = "请输入",
    this.icon,
    this.errorText,
    this.obscureText = false,
    this.tipText = "",
  })  : assert(icon != null),
        super(key: key);

  final String tipText;
  final String errorText;
  final TextEditingController controller;
  final String placeHolder;
  final IconData icon;
  final bool obscureText;

  bool get hasError => errorText != null && errorText != "";

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(30),
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          buildTextField(),
          Container(
            height: 30,
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: buildTip(),
          )
        ],
      ),
    );
  }

  Widget buildTextField() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        style: TextStyle(
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: placeHolder,
          hintStyle: TextStyle(color: Color(0xffa3a3a3)),
          contentPadding: EdgeInsets.zero,
          prefixIcon: SizedBox(
            child: Center(
              widthFactor: 0.0,
              child: Icon(icon, color: Color(0xffa3a3a3)),
            ),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: hasError ? Color(0xfff5222d): Color(0xffa3a3a3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: hasError ? Color(0xfff5222d) : Colors.blue,
              )),
        ),
      ),
    );
  }

  Widget buildTip() {
    if (hasError) {
      return Text(
        errorText,
        textAlign: TextAlign.start,
        style: TextStyle(color: Color(0xfff5222d)),
      );
    } else {
      return Text(
        tipText,
        textAlign: TextAlign.start,
        style: TextStyle(color: Colors.grey),
      );
    }
  }

}
