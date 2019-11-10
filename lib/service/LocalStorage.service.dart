import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final _prefix = 'localstorage_';

  static Future<bool> setString(String key, String str) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('$_prefix$key', str);
  }

  static Future<bool> setStringList(String key, List<String> strList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList('$_prefix$key', strList);
  }

  static Future<List<String>> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_prefix$key');
  }

  static Future<String> getString(String key ) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

}