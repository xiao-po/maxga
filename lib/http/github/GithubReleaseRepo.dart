
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maxga/model/github/GithubRelease.dart';
class GithubReleaseRepo {
  static Future<GithubRelease> getLatestReleaseInfo() async  {
    final response = await http.get('https://api.github.com/repos/xiao-po/maxga/releases/21522995');
    return GithubRelease.fromJson(json.decode(response.body));
  }
}