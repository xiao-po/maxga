import 'dart:async';
import 'dart:convert';

import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjLatestUpdateManga.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjMangaInfo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjMangaSearchResult.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjRankedMangaInfo.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';

import 'constants/DmzjMangaSource.dart';
import 'model/DmzjSearchSuggestion.dart';

class DmzjDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = DmzjMangaSource;
  MaxgaHttpUtils _httpUtils = MaxgaHttpUtils(DmzjMangaSource);

  @override
  Future<Manga> getMangaInfo(String url) async {
    return _httpUtils.requestApi<Manga>(url,
        parser: (response) =>
            DmzjMangaInfo.fromJson(json.decode(response.data)).convertToManga()
              ..infoUrl = url);
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/latest/100/$page.json',
        parser: (response) => (json.decode(response.data) as List<dynamic>)
            .map((item) => DmzjLatestUpdateManga.fromJson(item)
                .convertToSimpleMangaInfoForLatestUpdate())
            .toList());
  }

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestApi<List<String>>(url,
        parser: (response) =>
            json.decode(response.data)['page_url'].cast<String>());
  }

  @override
  Future<List<String>> getSuggestion(String words) async {
    return _httpUtils.requestApi<List<String>>(
        '${_source.apiDomain}/search/fuzzy/0/$words.json',
        parser: (response) => (json.decode(response.data) as List<dynamic>)
            .map((item) => DmzjSearchSuggestion.fromJson(item))
            .map((item) => item.title.replaceFirst('+', ''))
            .toList(growable: false));
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/rank/0/0/0/$page.json',
        parser: (response) => (json.decode(response.data) as List<dynamic>)
            .map((item) => DmzjRankedMangaInfo.fromJson(item)
                .convertToSimpleMangaInfoForRank())
            .toList(growable: false));
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/search/show/0/$keywords/0.json',
        parser: (response) => (json.decode(response.data) as List<dynamic>)
            .map((item) => DmzjMangaSearchResult.fromJson(item))
            .map((item) => item.convertToSimpleMangaInfoForSearchResult())
            .toList(growable: false));
  }

  // ignore: unused_element
  Chapter _convertDataFromChapterInfo(Map<String, dynamic> json) {
    final chapter = Chapter();
    chapter.title = json['title'];
    chapter.id = json['chapter_id'];
    chapter.order = json['chapter_order'];
    chapter.comicId = json['comic_id'];
    chapter.direction = json['direction'];
    chapter.imgUrlList = json['page_url'].cast<String>();
    return chapter;
  }

  @override
  get mangaSource => _source;

  @override
  Future<String> generateShareLink(Manga manga) {
    return Future.value('${_source.domain}/info/${manga.id}.html');
  }
}
