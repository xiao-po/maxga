import 'dart:convert';

import 'package:maxga/components/MangaOutlineButton.dart';
import 'package:maxga/model/user/User.dart';
import 'package:maxga/service/LocalStorage.service.dart';
import 'package:maxga/service/MaxgaServer.service.dart';
import 'package:maxga/service/user.service.dart';

import '../base/BaseProvider.dart';

class UserProvider  extends BaseProvider {
  User user;
  DateTime lastSyncTime;

  bool isFirstOpen = false;
  bool get isLogin => user != null;

  String get token => user?.token ?? null;

  static String _userStorageKey = "\$userStorage";
  static String _syncTimeKey = "\$syncTimeKey";
  static String _firstOpenKey = "\$firstOpenKey";
  static UserProvider _instance;

  static UserProvider getInstance() {
    if (_instance == null) {
      _instance = UserProvider();
    }
    return _instance;
  }

  init() async {
    await this._loadLoginStatus();
    await this._loadSyncTime();
    await this._loadFirstOpenStatus();
    if (this.isFirstOpen) {
      await this._setFirstOpenTime();
    }
  }

  Future<void> _loadSyncTime() async {
    final syncTimeString = await LocalStorage.getString(_syncTimeKey);
    if (syncTimeString != null) {
      this.lastSyncTime = DateTime.parse(
          syncTimeString
      );
    }
  }

  Future<void> sync() async {
    final syncTime = DateTime.now();
    await MaxgaServerService.sync();
    await MaxgaServerService.syncReadStatus();
    await LocalStorage.setString(_syncTimeKey, syncTime.toIso8601String());
    this.lastSyncTime = syncTime;
    notifyListeners();
  }

  void setLoginStatus(User user) async {
    await LocalStorage.setString(_userStorageKey, json.encode(user));
    isFirstOpen = false;
    this.user = user;
    notifyListeners();
  }

  Future<void> _loadLoginStatus() async {
    var userStorageString = await LocalStorage.getString(_userStorageKey);
    if (userStorageString == null) {
      return null;
    }
    var user = User.fromJson(
        json.decode(userStorageString)
    );

    this.user = user;
    notifyListeners();
  }

  Future<void> logout() async {
//    await LocalStorage.clearItem(_userStorageKey);
//    await UserService.logout(user.refreshToken);
    this.user = null;
    notifyListeners();
  }

  refreshTokenAndSave() async {
    try {
      String token = await UserService.refreshToken(this.user.refreshToken);
      var json = this.user.toJson();
      json['token'] = token;
      User user = User.fromJson(json);
      this.setLoginStatus(user);
    }catch(e) {
      print(e);
    }
  }

  Future<void> _loadFirstOpenStatus() async {
    String firstOpenTimeString = await LocalStorage.getString(_firstOpenKey);
    this.isFirstOpen = firstOpenTimeString == null;
  }

  Future<void> _setFirstOpenTime() async {
    await LocalStorage.setString(_firstOpenKey, DateTime.now().toIso8601String());
  }

}