import 'dart:convert';

import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaReadStorageService {
  static final String _key = 'manga_process_';
  static List<ReadMangaStatus> _readMangaStatusList;


  static Future<ReadMangaStatus> getMangaStatus(Manga manga) async {
    final allReadManga = await _getAllReadManga();
    final index = allReadManga.indexWhere((el) => el.infoUrl == manga.infoUrl);
    if (index == -1) {
      return null;
    }
    final mangaReadProcess = allReadManga[index]..chapterList.forEach((item) => item.isCollectionLatestUpdate = false);
    return mangaReadProcess;
  }

  static Future<List<ReadMangaStatus>> getAllCollectedManga() async {
    final allReadManga = await _getAllReadManga();
    allReadManga.removeWhere((el) => el.isCollected == false);
    return allReadManga.toList();
  }

  static Future<bool> setMangaStatus(ReadMangaStatus process) async {
    final allReadManga = await _getAllReadManga();
    allReadManga..removeWhere((el) => el.id == process.id)..add(process);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, allReadManga?.map((el) => json.encode(el))?.toList(growable: false) ?? []);
    return true;
  }

  static Future<List<ReadMangaStatus>> _getAllReadManga() async {
    if (MangaReadStorageService._readMangaStatusList == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      MangaReadStorageService._readMangaStatusList = prefs
          .getStringList(_key)
          ?.map((el) => ReadMangaStatus.fromJson(json.decode(el)))
          ?.toList() ??
          [];
    }
    return MangaReadStorageService._readMangaStatusList.toList();

  }

  static Future<void> clearStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }
}
