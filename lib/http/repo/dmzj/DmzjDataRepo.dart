import 'dart:async';
import 'dart:convert';

import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjMangaInfo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:http/http.dart' as http;
import 'package:maxga/model/MangaSource.dart';

import 'model/DmzjSearchSuggestion.dart';

class DmzjDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '动漫之家',
    key: 'dmzj'
  );

  @override
  Future<Manga> getMangaInfo({id, url}) async {
    if (url != null) {
    }
    final response = await http.get('http://v3api.dmzj.com/comic/comic_$id.json');
    return _convertDataFromMangaInfo(json.decode(response.body), id);
  }


  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    final response = await http.get('http://v3api.dmzj.com/latest/100/$page.json');
    final responseData = (json.decode(response.body) as List<dynamic>);
    return responseData.map((item) => _convertDataFromListItem(item)).toList();
  }


  @override
  Future<List<String>> getChapterImageList(String url) async {
    final response = await http.get(url);

    return json.decode(response.body)['page_url'].cast<String>();
  }


  @override
  Future<List<String>> getSuggestion(String words) async {
    final response = await http.get('http://v3api.dmzj.com/search/fuzzy/0/$words.json');
    try{
      final responseData = (json.decode(response.body) as List<dynamic>);
      return responseData.map((item) => DmzjSearchSuggestion.fromJson(item)).map((item) => item.title.replaceFirst('+', '')).toList();
    } catch(e) {
      print(response.request.url);
      throw e;
    }

  }


  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    final response = await http.get('http://v3api.dmzj.com/search/show/0/$keywords/0.json');
    final responseData = (json.decode(response.body) as List<dynamic>);
    return responseData.map((item) => _convertDataFromSearch(item)).toList();
  }



  /// 用于 动漫之家 列表拿到的接口返回的数据
  SimpleMangaInfo _convertDataFromListItem(Map<String, dynamic> json) {
    final SimpleMangaInfo manga = SimpleMangaInfo();

    final Chapter latestChapter = Chapter();
    latestChapter.id  = json['last_update_chapter_id'];
    latestChapter.title  = json['last_update_chapter_name'];
    latestChapter.updateTime  = json['last_updatetime'] * 1000;
    manga.lastUpdateChapter = latestChapter;
    manga.infoUrl = 'http://v3api.dmzj.com/comic/comic_${json['id']}.json';
    manga.author = json['authors'];
    manga.coverImgUrl = json['cover'];
    manga.title = json['title'];
    manga.id = json['id'];
    manga.typeList = (json['types'] as String).split('/');
    manga.source = _source;
    return manga;
  }

  /// 用于 动漫之家 列表拿到的接口返回的数据
  SimpleMangaInfo _convertDataFromSearch(Map<String, dynamic> json) {
    final SimpleMangaInfo manga = SimpleMangaInfo();

    final Chapter latestChapter = Chapter();
    latestChapter.title  = json['last_name'];
    manga.lastUpdateChapter = latestChapter;
    manga.infoUrl = 'http://v3api.dmzj.com/comic/comic_${json['id']}.json';
    manga.author = json['authors'];
    manga.coverImgUrl = json['cover'];
    manga.title = json['title'];
    manga.id = json['id'];
    manga.typeList = (json['types'] as String).split('/');
    manga.source = _source;
    return manga;
  }


  Manga _convertDataFromMangaInfo(Map<String, dynamic> json, int comicId) {
    final DmzjMangaInfo dmzjMangaInfo = DmzjMangaInfo.fromJson(json);
    final Manga manga = Manga();
    manga.author = dmzjMangaInfo.authors.map((tag) => tag.tagName).join('/');
    manga.introduce = dmzjMangaInfo.description;
    manga.typeList = dmzjMangaInfo.types.map((type) => type.tagName).toList();
    manga.title = dmzjMangaInfo.title;
    manga.coverImgUrl = dmzjMangaInfo.cover;
    manga.id = dmzjMangaInfo.id;
    manga.status = dmzjMangaInfo.status[0].tagName;
    manga.chapterList = dmzjMangaInfo.chapters.singleWhere((item) => item.title == '连载').data;
    manga.chapterList.forEach((chapter) {
      chapter.url = 'http://v3api.dmzj.com/chapter/$comicId/${chapter.id}.json';
    });
    manga.source = _source;
    return manga;
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


}
