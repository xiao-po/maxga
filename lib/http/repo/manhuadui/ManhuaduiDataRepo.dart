import 'package:maxga/http/repo/manhuadui/parser/ManhuaduiHtmlParser.dart';

import 'package:http/http.dart' as http;
import 'package:maxga/model/Manga.dart';
import 'package:maxga/model/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';
import 'crypto/ManhuaduiCrypto.dart';

class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
      name: '漫画堆',
      key: 'manhuadui'
  );
  ManhuaduiHtmlParser parser = ManhuaduiHtmlParser.getInstance();


  Future<List<String>> getChapterImageList(String url) async {
    final response = await http.get('https://www.manhuadui.com${url}');
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
  Future<List<Manga>> getLatestUpdate(int page) async {
    final response = await http.get('https://www.manhuadui.com/list/riben/update/$page/');

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
    final Manga mangaInfo = parser.getMangaFromMangaInfoPage(response.body);
    mangaInfo.chapterList.forEach((item) => item.comicId = id);
    mangaInfo.source = _source;
    return mangaInfo;
  }

  void testDecrypt(String s) {
    ManhuaduiCrypto.decrypt(s);
  }



}
