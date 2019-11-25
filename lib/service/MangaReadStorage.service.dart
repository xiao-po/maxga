import 'dart:convert';

import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaReadProcess.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaReadStorageService {
  static final String _key = 'manga_process_';
  static Future<MangaReadProcess> getMangaStatus(MangaBase manga) async {
    final allReadManga = await _getAllReadManga();
    final index = allReadManga.indexWhere((el) => el.id == manga.id && manga.source.key == el.sourceKey);
    return index != -1 ? allReadManga[index] : MangaReadProcess.empty(manga);
  }

  static Future<void> setMangaStatus(MangaReadProcess process) async {
    final allReadManga = await _getAllReadManga();
    allReadManga.removeWhere((el) => el.id == process.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, [...allReadManga?.map((el) => json.encode(el)) ?? [], json.encode(process)]);
  }

  static Future<List<MangaReadProcess>> _getAllReadManga() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key)?.map((el) => MangaReadProcess.fromJson(json.decode(el)))?.toList() ?? [];
  }
}