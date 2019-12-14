import 'package:maxga/http/repo/manhuadui/parser/ManhuaduiHtmlParser.dart';

import 'package:http/http.dart' as http;
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';

class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  MangaSource  _source = MangaSource(
      name: '漫画堆',
      key: 'manhuadui',
      domain: 'https://www.manhuadui.com',
      iconUrl:  'https://www.manhuadui.com/favicon.ico',
  );
  ManhuaduiHtmlParser parser = ManhuaduiHtmlParser.getInstance();


  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  Future<List<String>> getChapterImageList(String url) async {
    final response = await http.get('${_source.domain}$url');
    var chapterImageList = parser.getMangaImageListFromMangaPage(response.body);
    var chapterImagePath = parser.getMangaImagePathFromMangaPage(response.body);
    if (chapterImagePath == "") {
      chapterImageList = chapterImageList.map((url) => 'https://mhcdn.manhuazj.com/showImage.php?url=$url').toList(growable: false);
    } else {
      chapterImageList = chapterImageList.map((url) => 'https://mhcdn.manhuazj.com/$chapterImagePath$url').toList(growable: false);
    }
    return chapterImageList;
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    final response = await http.get('${_source.domain}/list/riben/update/$page/');

    final mangaList = parser.getMangaListFromLatestUpdate(response.body);
    mangaList.forEach((manga) => manga.sourceKey = _source.key);
    return mangaList;
  }




  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    final response = await http.get(url);
    final Manga mangaInfo = parser.getMangaFromMangaInfoPage(response.body);
    mangaInfo.chapterList.forEach((item) => item.comicId = id);
    mangaInfo.sourceKey = _source.key;
    mangaInfo.id = id;
    mangaInfo.infoUrl = url;
    return mangaInfo;
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {

    final response = await http.get('${_source.domain}/search/?keywords=$keywords');
    final List<SimpleMangaInfo> mangaList = parser.getMangaListFromSearch(response.body);
    mangaList.forEach((item) => item.sourceKey = _source.key);
    return mangaList;
  }

  @override
  MangaSource get mangaSource => _source;

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    if (page >= 1) {
      return [];
    }
    final response = await http.get('https://m.manhuadui.com/rank/click/');
    final List<SimpleMangaInfo> mangaList = parser.getMangaListFromRank(response.body)..forEach((el) => el.sourceKey = _source.key);
    return mangaList;
  }






}
