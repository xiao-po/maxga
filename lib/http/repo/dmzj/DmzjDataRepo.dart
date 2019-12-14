import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjMangaInfo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjRankedMangaInfo.dart';
import 'package:maxga/model/manga/Chapter.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:http/http.dart' as http;
import 'package:maxga/model/manga/MangaSource.dart';

import 'model/DmzjSearchSuggestion.dart';

class DmzjDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '动漫之家',
    key: 'dmzj',
    domain: 'https://v3api.dmzj.com',
    iconUrl:  'https://www.dmzj.com/favicon.ico',
    headers: {
      'referer': 'http://m.dmzj.com/latest.html',
    }
  );

  @override
  Future<Manga> getMangaInfo({id, url}) async {
    var response;
    try {
      if (id != null) {
        response = await http.get('${_source.domain}/comic/comic_$id.json');
      } else  {
        response = await http.get(url);
      }
    } catch(e) {
      throw MaxgaHttpError('动漫之家接口获取漫画详情失败', _source);
    }
    return _convertDataFromMangaInfo(json.decode(response.body), id);
  }


  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    try {
      final response = await http.get('${_source.domain}/latest/100/$page.json');
      final responseData = (json.decode(response.body) as List<dynamic>);
      return responseData.map((item) => _convertDataFromListItem(item)).toList();
    } catch(e) {
      throw MaxgaHttpError('动漫之家接口获取最近更新失败', _source);
    }
  }


  @override
  Future<List<String>> getChapterImageList(String url) async {
    Response response;
    try {
      response = await http.get(url);
    } catch(e) {
      throw MaxgaHttpError('动漫之家接口获取章节图片', _source);
    }
    return json.decode(response.body)['page_url'].cast<String>();
  }


  @override
  Future<List<String>> getSuggestion(String words) async {
    final response = await http.get('${_source.domain}/search/fuzzy/0/$words.json');
    try{
      final responseData = (json.decode(response.body) as List<dynamic>);
      return responseData.map((item) => DmzjSearchSuggestion.fromJson(item)).map((item) => item.title.replaceFirst('+', '')).toList();
    } catch(e) {
      print(response.request.url);
      throw e;
    }

  }


  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    final response = await http.get('${_source.domain}/rank/0/0/0/$page.json');
    return (json.decode(response.body) as List<dynamic>).map((item) => DmzjRankedMangaInfo.fromJson(item)).map((item) => _convertDataFromRankedManga(item)).toList(growable: false);
  }


  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    final response = await http.get('${_source.domain}/search/show/0/$keywords/0.json');
    final responseData = (json.decode(response.body) as List<dynamic>);
    return responseData.map((item) => _convertDataFromSearch(item)).toList();
  }

  SimpleMangaInfo _convertDataFromRankedManga(DmzjRankedMangaInfo rankedMangaInfo) {

    final SimpleMangaInfo manga = SimpleMangaInfo();

    final Chapter latestChapter = Chapter();
    latestChapter.title = rankedMangaInfo.lastUpdateChapterName;
    latestChapter.updateTime = int.parse(rankedMangaInfo.lastUpdatetime) * 1000;

    manga.id = int.parse(rankedMangaInfo.comicId);
    manga.title  = rankedMangaInfo.title;
    manga.sourceKey = _source.key;
    manga.typeList = rankedMangaInfo.types.split('/');
    manga.author = rankedMangaInfo.authors.split('/');
    manga.status = rankedMangaInfo.status;
    manga.coverImgUrl = rankedMangaInfo.cover;
    manga.infoUrl = 'http://v3api.dmzj.com/comic/comic_${rankedMangaInfo.comicId}.json';
    manga.lastUpdateChapter = latestChapter;
    return manga;
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
    manga.author = json['authors'].split('/');
    manga.coverImgUrl = json['cover'];
    manga.title = json['title'];
    manga.id = json['id'];
    manga.typeList = (json['types'] as String).split('/');
    manga.sourceKey = _source.key;
    return manga;
  }

  /// 用于 动漫之家 列表拿到的接口返回的数据
  SimpleMangaInfo _convertDataFromSearch(Map<String, dynamic> json) {
    final SimpleMangaInfo manga = SimpleMangaInfo();

    final Chapter latestChapter = Chapter();
    latestChapter.title  = json['last_name'];
    manga.lastUpdateChapter = latestChapter;
    manga.infoUrl = '${_source.domain}/comic/comic_${json['id']}.json';
    manga.author = json['authors'].split('/');
    manga.coverImgUrl = json['cover'];
    manga.title = json['title'];
    manga.id = json['id'];
    manga.typeList = (json['types'] as String).split('/');
    manga.sourceKey = _source.key;
    return manga;
  }


  Manga _convertDataFromMangaInfo(Map<String, dynamic> json, int comicId) {
    final DmzjMangaInfo dmzjMangaInfo = DmzjMangaInfo.fromJson(json);
    final Manga manga = Manga();
    manga.author = dmzjMangaInfo.authors.map((tag) => tag.tagName).toList(growable: false);
    manga.introduce = dmzjMangaInfo.description;
    manga.typeList = dmzjMangaInfo.types.map((type) => type.tagName).toList();
    manga.title = dmzjMangaInfo.title;
    manga.coverImgUrl = dmzjMangaInfo.cover;
    manga.id = dmzjMangaInfo.id;
    manga.status = dmzjMangaInfo.status[0].tagName;
    manga.chapterList = dmzjMangaInfo.chapters.singleWhere((item) => item.title == '连载').data;
    manga.chapterList.forEach((chapter) {
      chapter.url = '${_source.domain}/chapter/$comicId/${chapter.id}.json';
    });
    manga.sourceKey = _source.key;
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
