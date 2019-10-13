import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:maxga/http/repo/manhuadui/crypto/ManhuaduiCrypto.dart';
import 'package:maxga/model/Chapter.dart';

import 'package:maxga/model/Manga.dart';

class ManhuaduiHtmlParser {
  static ManhuaduiHtmlParser _instance;

  static ManhuaduiHtmlParser getInstance() {
    if (_instance == null) {
      _instance = ManhuaduiHtmlParser();
    }
    return _instance;
  }

  List<Manga> getMangaListFromLatestUpdate(String html) {
    var document = parse(html);
    var listComicNodeList = document.querySelector('.list_con_li.clearfix').querySelectorAll('.list-comic');
    final list = listComicNodeList.map((comicNode) => _parseMangaFromListComicNode(comicNode)).toList();
    return list;
  }

  Manga getMangaFromMangaInfoPage(String body) {
    var document = parse(body);
    return _parseMangaFromInfoPage(document);
  }


  List<String> getMangaImageListFromMangaPage(String html) {
    var document = parse(html);
    final body = document.body;
    final imageKeyScript = body.querySelector('script');
    final imageListEncryptText = imageKeyScript.innerHtml.substring(
        imageKeyScript.innerHtml.indexOf('chapterImages = "') + 17,
        imageKeyScript.innerHtml.indexOf('";')
    );
    final jsonResult = json.decode(
        ManhuaduiCrypto.decrypt(imageListEncryptText)
    ) as List;

    List<String> imageList = jsonResult.map((str) => '$str').toList(growable: false);

    return imageList;
  }


  String getMangaImagePathFromMangaPage(String html) {
    var document = parse(html);
    final body = document.body;
    final imageKeyScript = body.querySelector('script');

    final imagePath = imageKeyScript.innerHtml.substring(
        imageKeyScript.innerHtml.indexOf('chapterPath = "') + 15,
        imageKeyScript.innerHtml.indexOf('";var chapterPrice')
    );

    return imagePath;
  }


  Manga _parseMangaFromListComicNode(Element el) {
    final comicId = el.attributes['data-key'];
    final imageNode = el.querySelector('.comic_img').querySelector('img');
    final mangaInfoUrl = el.querySelector('.comic_img').attributes['href'];
    final mangaCoverUrl = imageNode.attributes['src'];
    final mangaTitle = imageNode.attributes['alt'];

    final mangaIntroNode = el.querySelectorAll('.comic_list_det p');
    final mangaAuthor = mangaIntroNode[0].innerHtml.replaceAll('作者：', '');
    final mangaTag = mangaIntroNode[1].innerHtml.replaceAll('类型：', '');
    final mangaExistStatus =  mangaIntroNode[2].innerHtml.replaceAll('状态：', '');
    final lastChapterTitle = mangaIntroNode[3].querySelector('a').innerHtml;

    Manga manga = Manga();
    manga.cover = mangaCoverUrl;
    manga.title = mangaTitle;
    manga.id = int.parse(comicId);
    manga.status = mangaExistStatus;
    manga.author = mangaAuthor;
    manga.typeList = mangaTag.split('/');
    manga.infoUrl = mangaInfoUrl;

    Chapter lastChapter = Chapter();
    lastChapter.title = lastChapterTitle;

    manga.chapterList = [lastChapter];

    return manga;
  }

  Manga _parseMangaFromInfoPage(Document document) {
    var introNode = document.querySelector('.wrap_intro_l_comic');
    final mangaCoverUrl = introNode.querySelector('.comic_i_img').querySelector('img').attributes['src'];

    var mangaInfoNode = introNode.querySelector('.comic_deCon');
    final mangaTitle = mangaInfoNode.querySelector('h1').innerHtml;
    final mangaIntroString = mangaInfoNode.querySelector('.comic_deCon_d').innerHtml.trim();

    var mangaMoreInfoNodeList = mangaInfoNode.querySelector('.comic_deCon_liO').children;
    final mangaAuthor = mangaMoreInfoNodeList[0].querySelector('a').innerHtml;
    final mangaTag = mangaMoreInfoNodeList[3].querySelector('a').innerHtml;
    final mangaExistStatus =  mangaMoreInfoNodeList[1].querySelector('a').innerHtml.replaceAll('状态：', '');


    var mangaChapterListNode = document.querySelectorAll('.zj_list')[1];
    final updateTime = mangaChapterListNode
        .querySelector('.zj_list_head')
        .querySelector('.zj_list_head_dat')
        .innerHtml
        .replaceAll('[ 更新时间：', '')
        .replaceAll(']', '').trim();

    var mangaChapterNodeList = mangaChapterListNode.querySelector('.zj_list_con').querySelectorAll('li').toList();

    var chapterIndex = 0;
    List<Chapter> chapterList = mangaChapterNodeList.map((node) {
      final chapter = Chapter();
      chapter.title = node.querySelector('a').attributes['title'];
      var url = node.querySelector('a').attributes['href'];
      var id = _getIdFromUrl(url);
      chapter.id = int.parse(id);
      chapter.order = chapterIndex;
      chapterIndex++;
      chapter.url = url;
      return chapter;
    }).toList();
    chapterList.sort((a, b) => b.order - a.order);

    var manga = Manga();
    manga.cover = mangaCoverUrl;
    manga.title = mangaTitle;
    manga.status = mangaExistStatus;
    manga.author = mangaAuthor;
    manga.typeList = mangaTag.split(' | ');
    manga.introduce = mangaIntroString;
    manga.chapterList = chapterList;

    return manga;

  }

  String _getIdFromUrl(String url) {
      return url.substring(
        url.lastIndexOf('/') + 1,
        url.lastIndexOf('.')
      );
  }




}
