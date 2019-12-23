import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:maxga/Utils/DateUtils.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'package:maxga/http/repo/manhuadui/crypto/ManhuaduiCrypto.dart';
import 'package:maxga/model/manga/Chapter.dart';

import 'package:maxga/model/manga/Manga.dart';

class ManhuaduiHtmlParser {
  static ManhuaduiHtmlParser _instance;

  static ManhuaduiHtmlParser getInstance() {
    if (_instance == null) {
      _instance = ManhuaduiHtmlParser();
    }
    return _instance;
  }

  List<SimpleMangaInfo> getMangaListFromLatestUpdate(String html) {
    var document = parse(html);
    var listComicNodeList = document
        .querySelector('.list_con_li.clearfix')
        .querySelectorAll('.list-comic');
    final list = listComicNodeList
        .map((comicNode) => _parseMangaFromListComicNode(comicNode))
        .toList();
    return list;
  }

  List<SimpleMangaInfo> getMangaListFromSearch(String html) {
    var document = parse(html);
    var listComicNodeList =
    document.querySelector('.update_con').querySelectorAll('.list-comic');
    final list = listComicNodeList
        .map((comicNode) => _parseMangaFromSearchComicNode(comicNode))
        .toList();
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

    final imagePath = imageKeyScript.innerHtml.substring(
        imageKeyScript.innerHtml.indexOf('chapterPath = "') + 15,
        imageKeyScript.innerHtml.indexOf('";var chapterPrice'));
    final imageListEncryptText = imageKeyScript.innerHtml.substring(
        imageKeyScript.innerHtml.indexOf('chapterImages = "') + 17,
        imageKeyScript.innerHtml.indexOf('";'));
    final jsonResult =
    json.decode(ManhuaduiCrypto.decrypt(imageListEncryptText)) as List;

    List<String> imageList =
    jsonResult.map((str) => '$str').toList(growable: false);
    if (imagePath == "") {
      return imageList
          .map((url) => 'https://mhcdn.manhuazj.com/showImage.php?url=$url')
          .toList(growable: false);
    } else {
      return imageList
          .map((url) => 'https://mhcdn.manhuazj.com/$imagePath$url')
          .toList(growable: false);
    }
  }

  String getMangaImagePathFromMangaPage(String html) {
    var document = parse(html);
    final body = document.body;
    final imageKeyScript = body.querySelector('script');

    final imagePath = imageKeyScript.innerHtml.substring(
        imageKeyScript.innerHtml.indexOf('chapterPath = "') + 15,
        imageKeyScript.innerHtml.indexOf('";var chapterPrice'));

    return imagePath;
  }

  SimpleMangaInfo _parseMangaFromListComicNode(Element el) {
    final comicId = el.attributes['data-key'];
    final imageNode = el.querySelector('.comic_img').querySelector('img');
    final mangaInfoUrl = el
        .querySelector('.comic_img')
        .attributes['href'];
    final mangaCoverUrl = imageNode.attributes['src'];
    final mangaTitle = imageNode.attributes['alt'];

    final mangaIntroNode = el.querySelectorAll('.comic_list_det p');
    final mangaAuthor = mangaIntroNode[0].innerHtml.replaceAll('作者：', '');
    final mangaTag = mangaIntroNode[1].innerHtml.replaceAll('类型：', '');
    final mangaExistStatus = mangaIntroNode[2].innerHtml.replaceAll('状态：', '');
    final lastChapterTitle = mangaIntroNode[3]
        .querySelector('a')
        .innerHtml;

    Chapter lastChapter = Chapter();
    lastChapter.title = lastChapterTitle;

    return SimpleMangaInfo.fromMangaRepo(
      sourceKey: ManhuaduiMangaSource.key,
      id: int.parse(comicId),
      infoUrl: mangaInfoUrl,
      coverImgUrl: mangaCoverUrl,
      title: mangaTitle,
      typeList: mangaTag.split('/'),
      author: mangaAuthor.split(','),
      status: mangaExistStatus,
      lastUpdateChapter: lastChapter,
    );
  }

  SimpleMangaInfo _parseMangaFromSearchComicNode(Element el) {
    final comicId = el.attributes['data-key'];
    final imageNode = el.querySelector('.image-link').querySelector('img');
    final mangaInfoUrl = el
        .querySelector('.image-link')
        .attributes['href'];
    final mangaCoverUrl = imageNode.attributes['src'];
    final mangaTitle = el
        .querySelector('.image-link')
        .attributes['title'];

    final mangaAuthor = el
        .querySelector('.auth')
        .innerHtml;
    final lastChapterTitle = el
        .querySelector('.newPage')
        .innerHtml;


    Chapter lastChapter = Chapter();
    lastChapter.title = lastChapterTitle;

    return SimpleMangaInfo.fromMangaRepo(
      sourceKey: ManhuaduiMangaSource.key,
      id: int.parse(comicId),
      infoUrl: mangaInfoUrl,
      coverImgUrl: mangaCoverUrl,
      title: mangaTitle,
      typeList: null,
      author: mangaAuthor.split(','),
      status: null,
      lastUpdateChapter: lastChapter,
    );
  }

  Manga _parseMangaFromInfoPage(Document document) {
    var introNode = document.querySelector('.wrap_intro_l_comic');
    final mangaCoverUrl = introNode
        .querySelector('.comic_i_img')
        .querySelector('img')
        .attributes['src'];

    var mangaInfoNode = introNode.querySelector('.comic_deCon');
    final mangaTitle = mangaInfoNode
        .querySelector('h1')
        .innerHtml;
    final mangaIntroString =
    mangaInfoNode
        .querySelector('.comic_deCon_d')
        .innerHtml
        .trim();

    var mangaMoreInfoNodeList =
        mangaInfoNode
            .querySelector('.comic_deCon_liO')
            .children;
    final mangaAuthor = mangaMoreInfoNodeList[0]
        .querySelector('a')
        .innerHtml;
    final mangaTag = mangaMoreInfoNodeList[3]
        .querySelector('a')
        .innerHtml;
    final mangaExistStatus = mangaMoreInfoNodeList[1]
        .querySelector('a')
        .innerHtml
        .replaceAll('状态：', '');

    var mangaChapterListNode = document.querySelectorAll('.zj_list')[1];
    // ignore: unused_local_variable
    final updateTime = mangaChapterListNode
        .querySelector('.zj_list_head')
        .querySelector('.zj_list_head_dat')
        .innerHtml
        .replaceAll('[ 更新时间：', '')
        .replaceAll(']', '')
        .trim();

    var mangaChapterNodeList = mangaChapterListNode
        .querySelector('.zj_list_con')
        .querySelectorAll('li')
        .toList();

    var chapterIndex = 0;
    List<Chapter> chapterList = mangaChapterNodeList.map((node) {
      final chapter = Chapter();
      chapter.title = node
          .querySelector('a')
          .attributes['title'];
      var url = node
          .querySelector('a')
          .attributes['href'];
      var id = _getIdFromUrl(url);
      chapter.id = int.parse(id);
      chapter.order = chapterIndex;
      chapterIndex++;
      chapter.url = url;
      return chapter;
    }).toList();
    chapterList.sort((a, b) => b.order - a.order);

    return Manga.fromMangaInfoRequest(
        authors: mangaAuthor.split(','),
        types: mangaTag.split(' | '),
        introduce: mangaIntroString,
        title: mangaTitle,
        id: 0,
        infoUrl: '',
        status: mangaExistStatus,
        coverImgUrl: mangaCoverUrl,
        sourceKey: ManhuaduiMangaSource.key,
        chapterList: chapterList);
  }

  List<SimpleMangaInfo> getMangaListFromRank(String body) {
    var document = parse(body);
    return document
        .querySelector('#topImgCon')
        .querySelector('.items')
        .children
        .map((Element el) {
      final mangaId = el.attributes['data-key'];
      final mangaCoverUrl =
      el
          .querySelector('.itemImg')
          .querySelector('img')
          .attributes['src'];
      final infoNode = el.querySelector('.itemTxt');
      final titleNode = infoNode.querySelector('.title');
      final mangaTitle = titleNode.innerHtml;
      final mangaInfoUrl = titleNode.attributes['href'];
      final mangaAuthors = infoNode.children[1].text.split(',');
      final mangaTypeList = infoNode.children[2].text.split('|');
      final mangaUpdateTime = DateUtils.convertTimeStringToTimestamp(
          infoNode.children[3]
              .querySelector('.date')
              .innerHtml,
          'yyyy-MM-dd hh:mm');


      Chapter lastChapter = Chapter();
      lastChapter.title = '';
      lastChapter.updateTime = mangaUpdateTime;


      return SimpleMangaInfo.fromMangaRepo(
        sourceKey: ManhuaduiMangaSource.key,
        id: int.parse(mangaId),
        infoUrl: mangaInfoUrl,
        coverImgUrl: mangaCoverUrl,
        title: mangaTitle,
        typeList: mangaTypeList,
        author: mangaAuthors,
        status: null,
        lastUpdateChapter: lastChapter,
      );
    }).toList(growable: false);
  }

  String _getIdFromUrl(String url) {
    return url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));
  }
}

//class _MobileParserBak {
//
//  List<SimpleMangaInfo> getSimpleMangaInfoListFromUpdatePage(String body) {
//    final document = parse(body);
//    return document.querySelector('.page-main').querySelector('.UpdateList').querySelectorAll('.itemBox').map((el) => _getSimpleMangaInfoFromItemBox(el)).toList(growable: false);
//  }
//
//  SimpleMangaInfo _getSimpleMangaInfoFromItemBox(Element el) {
//    final mangaId = el.attributes['data-key'];
//    final coverImageUrl = el.querySelector('.itemImg').querySelector('img').attributes['src'];
//    final itemTxtEl = el.querySelector('.itemTxt');
//    final title = itemTxtEl.children[0].innerHtml;
//    final mangaInfoUrl = itemTxtEl.children[0].attributes['href'];
//    final authors = itemTxtEl.children[1].text.split('|');
//    final types = itemTxtEl.children[2].children[1].innerHtml.split('|');
//    final updateTime = DateUtils.convertTimeStringToTimestamp(
//        itemTxtEl.children[3].children[1].innerHtml
//        , 'yyyy-MM-dd hh:mm'
//    );
//    final updateEl = el.querySelector('.coll');
//    final lastChapterTitle = updateEl.innerHtml;
//    final lastChapterUrl = updateEl.attributes['href'];
//
//
//    final SimpleMangaInfo manga = SimpleMangaInfo();
//    manga.id = int.parse(mangaId);
//    manga.coverImgUrl = coverImageUrl;
//    manga.title = title;
//    manga.author = authors;
//    manga.typeList = types;
//    manga.infoUrl = mangaInfoUrl;
//    final lastUpdateChapter = Chapter();
//    lastUpdateChapter.title = lastChapterTitle;
//    lastUpdateChapter.updateTime = updateTime;
//    lastUpdateChapter.url = lastChapterUrl;
//
//    manga.lastUpdateChapter = lastUpdateChapter;
//
//    return manga;
//
//
//  }
//
//  Manga getMangaInfo(String body) {
//    final document = parse(body);
//    final bodyEl = document.querySelector('.Introduct');
//    final title = bodyEl.querySelector('#comicName').innerHtml;
//    final otherInfoMainEl = bodyEl.querySelector('.Introduct_Sub');
//    final coverImageUrl = otherInfoMainEl.querySelector('.pic').querySelector('img').attributes['href'];
//    final otherInfoEl = otherInfoMainEl.querySelector('.sub_r');
//
//    final authors = otherInfoEl.children[0].text.split(',');
//    final types = otherInfoEl.children[1].text.split(' | ');
//    final status = otherInfoEl.children[2].text.split(' ')[2];
//    final time = DateUtils.convertTimeStringToTimestamp(
//        otherInfoEl.children[4].children[1].innerHtml
//        , 'yyyy-MM-dd hh:mm'
//    );
//
//    final intro = bodyEl.querySelector('.txtDesc').innerHtml;
//    final chapterListEl = bodyEl.querySelector('#list_block').querySelector('#chapter-list-1').children.map((el) => el.children[0]);
//    var index = 1000;
//    final List<Chapter> chapterList = chapterListEl.map((el) {
//      Chapter chapter = Chapter();
//      chapter.url = el.attributes['href'];
//      chapter.title = el.children[0].innerHtml;
//      chapter.id = int.parse(
//          chapter.url.substring(
//            chapter.url.lastIndexOf('/') + 1,
//            chapter.url.lastIndexOf('.html'),
//          )
//      );
//      chapter.order = index--;
//      return chapter;
//    }).toList(growable: false);
//
//    final Manga manga = Manga();
//    manga.title = title;
//    manga.coverImgUrl = coverImageUrl;
//    manga.author = authors;
//    manga.typeList = types;
//    manga.status = status;
//    manga.introduce = intro;
//    manga.chapterList = chapterList;
//    return manga;
//
//  }
//}
