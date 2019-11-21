import 'dart:convert';

import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadHistoryService {
  static final String _key = 'read_history_';
  static Future<SimpleMangaInfo> getHistory() async {

  }

  static Future<void> setMangaStatus(SimpleMangaInfo process) async {
  }
}