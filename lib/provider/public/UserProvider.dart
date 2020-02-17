import 'dart:convert';

import 'package:maxga/http/server/base/MaxgaRequestError.dart';
import 'package:maxga/model/user/User.dart';
import 'package:maxga/service/LocalStorage.service.dart';
import 'package:maxga/service/MaxgaServer.service.dart';
import 'package:maxga/service/user.service.dart';

import '../base/BaseProvider.dart';

class UserProvider  extends BaseProvider {
  User user;
  DateTime lastSyncTime;

  bool get isLogin => user != null;

  static String _userStorageKey = "\$userStorage";
  static String _syncTimeKey = "\$syncTimeKey";
  static UserProvider _instance;

  static UserProvider getInstance() {
    if (_instance == null) {
      _instance = UserProvider();
    }
    return _instance;
  }

  init() async {
    await this.loadLoginStatus();
    await this.loadSyncTime();
  }

  Future<void> loadSyncTime() async {
    final syncTimeString = await LocalStorage.getString(_syncTimeKey);
    if (syncTimeString != null) {
      this.lastSyncTime = DateTime.parse(
          syncTimeString
      );
    }
  }

  Future<void> updateSyncTime() async {
    final syncTime = DateTime.now();
    await LocalStorage.setString(_syncTimeKey, syncTime.toIso8601String());
    this.lastSyncTime = syncTime;
    notifyListeners();
  }

  void setLoginStatus(User user) async {
    await LocalStorage.setString(_userStorageKey, json.encode(user));
    this.user = user;
    notifyListeners();
  }

  Future<void> loadLoginStatus() async {
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

  logout() async {
    this.user = null;
    await LocalStorage.clearItem(_userStorageKey);
    notifyListeners();
  }

  refreshTokenAndSave() async {
    try {
      String token = await UserService.refreshToken(this.user.refreshToken);

    }catch(e) {
      
    }
  }

}