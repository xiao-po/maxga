import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WillExitScope extends StatefulWidget {
  final Widget child;

  const WillExitScope({Key key, this.child}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _WillExitScopeState();

}

class _WillExitScopeState extends State<WillExitScope> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBack(),
      child: widget.child,
    );
  }
  void showSnack(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
  DateTime _lastPressedAt; //上次点击时间
  Future<bool> onBack() async {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 2)) {
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      showSnack('再按一次退出程序');
      return false;
    } else {
      await Future.delayed(Duration(milliseconds: 100));
      return true;
    }
  }

}

