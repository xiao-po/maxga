import 'dart:async';
import 'dart:convert';

import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjChapterData.dart';
import 'package:maxga/http/repo/dmzj/model/DmzjMangaInfo.dart';
import 'package:maxga/model/Chapter.dart';
import 'package:maxga/model/Manga.dart';
import 'package:http/http.dart' as http;
import 'package:maxga/model/MangaSource.dart';

class DmzjDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '动漫之家',
    key: 'dmzj'
  );

  @override
  Future<Manga> getMangaInfo(int mangaId) async {
    final response = await http.get('http://v3api.dmzj.com/comic/comic_$mangaId.json');
    return _convertDataFromMangaInfo(json.decode(response.body));
  }

  @override
  Future<List<Manga>> search() async {
    return Future(null);
  }

  @override
  Future<List<Manga>> getLatestUpdate(int page) async {
    final response = await http.get('http://v3api.dmzj.com/latest/100/${page}.json');
    final responseData = (json.decode(response.body) as List<dynamic>);
    return responseData.map((item) => _convertDataFromListItem(item)).toList();
  }


  @override
  Future<Chapter> getChapterInfo(int comicId, int chapterId) async {
    final response = await http.get('http://v3api.dmzj.com/chapter/$comicId/$chapterId.json');

    return _convertDataFromChapterInfo(json.decode(response.body));
  }


  /// 用于 动漫之家 列表拿到的接口返回的数据
  Manga _convertDataFromListItem(Map<String, dynamic> json) {
    final Manga manga = Manga();

    final Chapter latestChapter = Chapter();
    latestChapter.id  = json['last_update_chapter_id'];
    latestChapter.title  = json['last_update_chapter_name'];
    latestChapter.updateTime  = json['last_updatetime'] * 1000;
    manga.chapterList = [latestChapter];

    manga.author = json['authors'];
    manga.cover = json['cover'];
    manga.title = json['title'];
    manga.id = json['id'];
    manga.typeList = (json['types'] as String).split('/');
    manga.source = _source;
    return manga;
  }

  Manga _convertDataFromMangaInfo(Map<String, dynamic> json) {
    final DmzjMangaInfo dmzjMangaInfo = DmzjMangaInfo.fromJson(json);
    final Manga manga = Manga();
    manga.author = dmzjMangaInfo.authors.map((tag) => tag.tagName).join('/');
    manga.introduce = dmzjMangaInfo.description;
    manga.typeList = dmzjMangaInfo.types.map((type) => type.tagName).toList();
    manga.title = dmzjMangaInfo.title;
    manga.cover = dmzjMangaInfo.cover;
    manga.id = dmzjMangaInfo.id;
    manga.status = dmzjMangaInfo.status[0].tagName;
    manga.chapterList = dmzjMangaInfo.chapters.singleWhere((item) => item.title == '连载').data;
    manga.chapterList.forEach((chapter) => {});
    manga.source = _source;
    return manga;
  }

  Chapter _convertDataFromChapterInfo(Map<String, dynamic> json) {
    final chapter = Chapter();
    chapter.title = json['title'];
    chapter.id = json['chapter_id'];
    chapter.order = json['chapter_order'];
    chapter.comicId = json['comic_id'];
    chapter.direction = json['direction'];
    chapter.imgUrlList = json['page_url'].cast<String>();
    chapter.imageCount = json['picnum'];
    return chapter;
  }

}
