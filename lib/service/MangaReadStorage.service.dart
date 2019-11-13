import 'dart:convert';

import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaReadStorageService {
  static final String _key = 'manga_process_';
  static Future<MangaReadProcess> getMangaStatus(Manga manga) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('manga_process_${manga.source.key}_${manga.id}');
    var value = prefs.getString('$_key${manga.source.key}_${manga.id}');
    return value != null ? MangaReadProcess.fromJson(json.decode(value)) : null;
  }

  static Future<void> setMangaStatus(MangaReadProcess process) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('manga_process_${process.sourceKey}_${process.id}');
    await prefs.setString('$_key${process.sourceKey}_${process.id}', json.encode(process));
  }
}