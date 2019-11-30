
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MaxgaUtils {
  //初始化通信管道-设置退出到手机桌面
  static const String CHANNEL = "android/maxga/utils";
  //设置回退到手机桌面
  static Future<bool> backDeskTop() async {
    if (Platform.isIOS) {
      return true;
    }
    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('backDesktop');
      if (out) debugPrint('返回到桌面');
    } on PlatformException catch (e) {
      debugPrint("通信失败(设置回退到安卓手机桌面:设置失败)");
      print(e.toString());
    }
    return Future.value(false);
  }

  static Future<bool> hiddenStatusBar() async {
    if (Platform.isIOS) {
      return true;
    }
    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('hiddenStatusBar');
      return Future.value(out);
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return Future.value(false);
  }

  static Future<bool> showStatusBar() async {
    if (Platform.isIOS) {
      return true;
    }
    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('showStatusBar');
      return Future.value(out);
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return Future.value(false);
  }

  static Future<bool> shareUrl(String url) async {
    if (Platform.isIOS) {
      return true;
    }

    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('shareUrl', url);
      return out;
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return false;

  }
}

