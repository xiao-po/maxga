import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuagui/crypto/ManhuaguiCrypto.dart';
import 'package:maxga/http/repo/manhuagui/parser/ManhuaguiHtmlParser.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:http/http.dart' as http;
import 'package:maxga/model/manga/MangaSource.dart';

class ManhuaguiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '漫画柜',
    key: 'manhuagui',
    domain: 'https://m.manhuagui.com/',
    iconUrl:  'https://m.manhuagui.com/favicon.ico',
    headers: {
      'Referer': 'https://m.manhuagui.com/'
    }
  );
  ManhuaguiHtmlParser parser = ManhuaguiHtmlParser.getInstance();

  @override
  Future<List<String>> getChapterImageList(String url) async {
    final response = await http.get(url);
    final encryptImageString = parser.getEncryptImageString(response.body);
    return ManhuaguiCrypto.decrypt(encryptImageString).map((url) => 'https://i.hamreus.com$url').toList(growable: false);
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    final response = await http.get('${_source.domain}update/?page=$page&ajax=1&order=1');
    return parser.getSimpleMangaInfoListFromUpdatePage(response.body)..forEach((manga) {
      manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
      manga.sourceKey = _source.key;
    });
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    if (url == null) {
      throw Error.safeToString('${_source.name}不支持用 id 获取漫画详情');
    }
    final response = await http.get(url);
    Manga manga = parser.getMangaInfo(response.body);
    manga.chapterList.forEach((chapter) {
      chapter.url = '${_source.domain}${chapter.url.substring(1)}';
    });
    return manga;
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    final response = await http.get('https://m.manhuagui.com/s/$keywords.html');

    return parser.getSimpleMangaInfoFromSearch(response.body)..forEach((manga) {
      manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
      manga.sourceKey = _source.key;
    });
  }

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  MangaSource get mangaSource => _source;

}