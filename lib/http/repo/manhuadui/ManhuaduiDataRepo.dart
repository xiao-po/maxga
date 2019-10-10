import 'package:maxga/http/error/NotSupportWayToGetData.dart';
import 'package:maxga/http/repo/manhuadui/parser/ManhuaduiHtmlParser.dart';
import 'package:maxga/model/Chapter.dart';

import 'package:http/http.dart' as http;
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';

class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
      name: '漫画堆',
      key: 'manhuadui'
  );

  @override
  Future<Chapter> getChapterInfo(int comicId, int chapterId) {
    return null;
  }

  @override
  Future<List<Manga>> getLatestUpdate(int page) async {
    final response = await http.get('https://www.manhuadui.com/list/riben/update/$page/');
    ManhuaduiHtmlParser parser = ManhuaduiHtmlParser();
    final mangaList = parser.getMangaListFromLatestUpdate(response.body);
    mangaList.forEach((manga) => manga.source = _source);
    return mangaList;
  }



  @override
  Future<List<Manga>> search() {
    return null;
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    final response = await http.get(url);
    ManhuaduiHtmlParser parser = ManhuaduiHtmlParser();
    final Manga mangaInfo = parser.getMangaFromMangaInfoPage(response.body);
    mangaInfo.source = _source;
    return mangaInfo;
  }



}
