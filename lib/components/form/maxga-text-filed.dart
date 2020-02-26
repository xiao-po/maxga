import 'package:flutter/material.dart';
import 'package:maxga/constant/icons/antd-icon.dart';

import 'base/form-item.dart';

const _errorColorLighting = Color(0xfff5222d);
final _errorColorDark = Colors.red[300];

class MaxgaTextFiled extends StatelessWidget {
  MaxgaTextFiled.fromItem(
    FormItem item, {
    this.obscureText = false,
    @required this.icon,
    this.placeHolder = "请输入",
    this.tipText = "",
    this.suffixIcon,
  })  : this.controller = item.controller,
        this.errorText = item.errorText,
        this.disabled = item.disabled;

  const MaxgaTextFiled({
    Key key,
    @required this.controller,
    this.placeHolder = "请输入",
    @required this.icon,
    this.errorText,
    this.disabled = false,
    this.obscureText = false,
    this.tipText = "",
    this.suffixIcon,
  })  : assert(icon != null),
        super(key: key);

  final String tipText;
  final String errorText;
  final bool disabled;
  final TextEditingController controller;
  final String placeHolder;
  final Widget icon;
  final bool obscureText;
  final Widget suffixIcon;

  bool get hasError => errorText != null && errorText != "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var isDark = theme.brightness == Brightness.dark;
    var tip = Text(
      tipText,
      textAlign: TextAlign.start,
      style: TextStyle(color: Colors.grey),
    );
    if (hasError) {
      tip = Text(
        errorText,
        textAlign: TextAlign.start,
        style: TextStyle(color: isDark ? _errorColorDark : _errorColorLighting),
      );
    }
    return Material(
      borderRadius: BorderRadius.circular(30),
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          buildTextField(theme),
          Container(
            constraints: BoxConstraints(
              minHeight: 30,
            ),
            padding: EdgeInsets.only(top: 5, bottom: 5),
            width: double.infinity,
            child: tip,
          )
        ],
      ),
    );
  }

  Widget buildTextField(ThemeData theme) {
    var textFiledColor = disabled ? Colors.grey[200] : Colors.white;
    var isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      textFiledColor = disabled ? Colors.grey[200] : Colors.grey[800];
    }

    var enabledColor = hasError ? _errorColorLighting : Color(0xffa3a3a3);
    if (isDark) {
      enabledColor = hasError ? _errorColorDark : Color(0xffa3a3a3);
    }
    var focusBorderColor = hasError ? _errorColorLighting : theme.accentColor;
    if (isDark) {
      focusBorderColor = hasError ? _errorColorDark : theme.accentColor;
    }
    var textColor = disabled ? Colors.grey[500] : null;
    if (isDark) {
      textColor = disabled ? Colors.grey[500] : Colors.grey[300];
    }

    var prefixIconWidget = IconTheme.merge(
        data: IconThemeData(color: Color(0xffa3a3a3)), child: icon);
    var suffixIconWidget = IconTheme.merge(
        data: IconThemeData(color: Color(0xffa3a3a3)), child: suffixIcon);
    return Container(
      constraints: BoxConstraints(maxHeight: 40),
      decoration: BoxDecoration(
        color: textFiledColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        enabled: !disabled,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
        cursorColor: theme.accentColor,
        decoration: InputDecoration(
          hintText: placeHolder,
          hintStyle: TextStyle(color: Color(0xffa3a3a3)),
          contentPadding: EdgeInsets.zero,
          prefixIcon: SizedBox(
            child: Center(
              widthFactor: 0.0,
              child: prefixIconWidget,
            ),
          ),
          suffixIcon: suffixIcon != null
              ?suffixIconWidget
              : null,
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Color(0xffa3a3a3))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: enabledColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: focusBorderColor,
              )),
        ),
      ),
    );
  }
}
