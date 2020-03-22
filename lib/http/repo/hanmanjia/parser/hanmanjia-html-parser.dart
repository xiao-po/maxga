import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:maxga/http/repo/hanmanjia/constants/hanmanjia-repo-value.dart';
import 'package:maxga/model/manga/chapter.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/utils/date-utils.dart';

class HanmanjiaHtmlParser {
  static HanmanjiaHtmlParser _instance;

  static HanmanjiaHtmlParser getInstance() {
    if (_instance == null) {
      _instance = HanmanjiaHtmlParser();
    }
    return _instance;
  }

  List<SimpleMangaInfo> getMangaListFromLatestUpdate(String data) {
    final trimString = data.replaceAll(RegExp('\n'), '');
    var ulNodeString = '';
    try {
      ulNodeString =
          RegExp('<ul class="manga-list-2">(.+?)</ul>')
              .firstMatch(trimString)
              .group(1);
      if (ulNodeString.isEmpty) {
        throw Error();
      }
    } catch (e) {
      return [];
    }
    final ulNode = parseFragment(ulNodeString, container: 'ul');
    return ulNode.children.map((e) {
      var coverNode = e.firstChild;
      var infoUrl = coverNode.firstChild.attributes['href'];
      var coverImageUrl =
      coverNode.firstChild.firstChild.attributes['data-original'];
      var title = e.children[1].firstChild.text;
      var lastChapterTitle = e.children.last.firstChild.text;

      final lastChapter = Chapter();
      lastChapter.title = lastChapterTitle;
      return SimpleMangaInfo.fromMangaRepo(
          sourceKey: null,
          id: '',
          authors: [],
          infoUrl: '${HanmanjiaMangaSource.apiDomain}$infoUrl',
          coverImgUrl: coverImageUrl,
          typeList: [],
          lastUpdateChapter: lastChapter,
          title: title);
    }).toList();
  }

  Manga getMangaInfo(String data) {
    final html = parse(data.replaceAll(RegExp('\n'), ''));
    final detailMainNode = html.querySelector('.detail-main');
    final detailMainInfoNode = detailMainNode.children[2];
    final descNode = html.querySelector('.detail-desc');
    final chapterNode = html.querySelector('#chapter_indexes');
    final mangaStatusNode = chapterNode.firstChild;
    final chapterListNode = chapterNode.children[1];


    final title = detailMainInfoNode.firstChild.text;
    final author = detailMainInfoNode.children[2].children[0].text.split(',');
    final coverImageUrl = detailMainNode.firstChild.attributes['data-original'];
    final typeList = detailMainInfoNode.children.last.children.map((e) => e.firstChild.text).toList();
    final desc = descNode.text;
    final mangaStatus = mangaStatusNode.firstChild.text;
    final time = DateUtils.convertTimeStringToDateTime(
        mangaStatusNode.children[1].text.substring(0, 10), 'yyyy-MM-dd');
    var order = 1;
    final List<Chapter> chapterList = chapterListNode.children.map((e) {
      final chapter = Chapter();
      chapter.url =
      '${HanmanjiaMangaSource.domain}${e.firstChild.attributes['href']}';
      chapter.title = RegExp('第.+?话').firstMatch(e.children[0].text).group(0);
      chapter.order = order++;
      chapter.id = int.parse( chapter.url.split('/').last.split('-').first);
      return chapter;
    }).toList();

    chapterList.sort((a, b) => b.order - a.order);
    return Manga.fromMangaInfoRequest(
        authors: author,
        types: typeList,
        introduce: desc,
        title: title,
        id: '',
        infoUrl: '',
        status: mangaStatus,
        coverImgUrl: coverImageUrl,
        sourceKey: HanmanjiaMangaSource.key,
        chapterList: chapterList,
        latestChapter: chapterList.last.copyWith(updateTime: time));
  }

  List<String> getImageListFromChapter(String s) {

    final html = parse(s.replaceAll(RegExp('\n'), ''));
    final imageListNode = html.querySelector('#cp_img');
    return imageListNode.children.map((e) => e.attributes['data-original']).toList();

  }
}
