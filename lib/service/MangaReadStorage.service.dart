import 'dart:convert';

import 'package:maxga/database/mangaData.repo.dart';
import 'package:maxga/database/readMangaStatus.repo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaStorageService {
  static final String _key = 'manga_process_';
  static List<ReadMangaStatus> _readMangaStatusList;

  static List<ReadMangaStatus> _onDbReadMangaStatusList;

  static Future<bool> saveManga(Manga manga) async {

    final isMangaExist = await MangaDataRepository.isExist(manga.infoUrl);
    bool isSaveToMangaTableSuccess = false;
    if (isMangaExist) {
      isSaveToMangaTableSuccess = await MangaDataRepository.update(manga);
    } else {
      isSaveToMangaTableSuccess = await MangaDataRepository.insert(manga);
    }
    return isSaveToMangaTableSuccess;
  }

  static Future<Manga> getMangaByUrl(String url) {
    return MangaDataRepository.findByUrl(url);
  }

  static Future<List<Manga>> getCollectedManga() {
    return MangaDataRepository.findByIsCollected(true);

  }

  static Future<ReadMangaStatus> getMangaStatusByUrl(String url) async {
    return (await MangaReadStatusRepository.findByUrl(url)) ?? ReadMangaStatus(
      infoUrl: url
    );
  }

  static Future<bool> saveMangaStatus(ReadMangaStatus status) async {
    final isMangaReadStatusExist = await MangaReadStatusRepository.isExist(status.infoUrl);
    bool isSaveToMangaReadStatusTableSuccess = false;
    if (isMangaReadStatusExist) {
      isSaveToMangaReadStatusTableSuccess = await MangaReadStatusRepository.update(status);
    } else {
      isSaveToMangaReadStatusTableSuccess = await MangaReadStatusRepository.insert(status);
    }

    return true;
  }

  static Future<List<Manga>> getMangaByUrlList(List<String> urlList)  {
    if (urlList == null || urlList.isEmpty) {
      return Future.value([]);
    }
    return MangaDataRepository.findByUrlList(urlList);
  }

  static Future<bool> setMangaCollectedStatus(Manga manga, {bool isCollect = true}) async {
    ReadMangaStatus readMangaStatus = await MangaReadStatusRepository.findByUrl(manga.infoUrl);
    final isExist = readMangaStatus != null;
    if (isExist) {
      return MangaReadStatusRepository.update(readMangaStatus..isCollect = isCollect);
    } else {
      return MangaReadStatusRepository.insert(ReadMangaStatus(
        infoUrl: manga.infoUrl,
        isCollect: isCollect
      ));
    }

  }


//  static Future<ReadMangaStatus> getMangaStatus(Manga manga) async {
//    final allReadManga = (await _getAllReadManga()).toList();
//    final index = allReadManga.indexWhere((el) => el.infoUrl == manga.infoUrl);
//    if (index == -1) {
//      return null;
//    }
//    final mangaReadProcess = allReadManga[index]..chapterList.forEach((item) => item.isLatestUpdate = false);
//    return mangaReadProcess;
//  }
//
//  static Future<List<Manga>> getAllCollectedManga() async {
//    final allReadManga = (await _getAllReadManga()).toList();
//    allReadManga.removeWhere((el) => el.isCollected == false);
//    return allReadManga.toList();
//  }
//
//  static Future<bool> setMangaStatus(Manga process) async {
//    final allReadManga = await _getAllReadManga();
//    allReadManga..removeWhere((el) => el.infoUrl == process.infoUrl)..add(process);
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.setStringList(_key, allReadManga?.map((el) => json.encode(el))?.toList(growable: false) ?? []);
//    return true;
//  }
//
//  static Future<List<ReadMangaStatus>> _getAllReadManga() async {
//    if (MangaStorageService._readMangaStatusList == null) {
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      MangaStorageService._readMangaStatusList = prefs
//          .getStringList(_key)
//          ?.map((el) => ReadMangaStatus.fromJson(json.decode(el)))
//          ?.toList() ??
//          [];
//    }
//    return MangaStorageService._readMangaStatusList;

//  }

  static Future<void> clearStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }
}