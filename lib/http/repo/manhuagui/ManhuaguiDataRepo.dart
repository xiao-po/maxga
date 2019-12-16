import 'package:http/http.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuagui/crypto/ManhuaguiCrypto.dart';
import 'package:maxga/http/repo/manhuagui/parser/ManhuaguiHtmlParser.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
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
    Response response;
    try {
      response = await MaxgaHttpUtils.retryRequest(requestBuilder: () => http.get(url));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      final encryptImageString = parser.getEncryptImageString(response.body);
      return ManhuaguiCrypto.decrypt(encryptImageString).map((url) => 'https://i.hamreus.com$url').toList(growable: false);
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    Response response;
    final url = '${_source.domain}update/?page=${page + 1}&ajax=1&order=1';
    try {
      response = await  MaxgaHttpUtils.retryRequest(requestBuilder: () => http.get(url));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      return parser.getSimpleMangaInfoListFromUpdatePage(response.body)..forEach((manga) {
        manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
        manga.sourceKey = _source.key;
      });
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    if (url == null) {
      throw MangaHttpNullParamError(_source);
    }
    Response response;
    try {
      response = await  MaxgaHttpUtils.retryRequest(requestBuilder: () => http.get(url));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      Manga manga = parser.getMangaInfo(response.body);
      manga.chapterList.forEach((chapter) {
        chapter.url = '${_source.domain}${chapter.url.substring(1)}';
      });
      return manga;
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }

  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    Response response;
    try {
      response = await  MaxgaHttpUtils.retryRequest(requestBuilder: () => http.get('https://m.manhuagui.com/s/$keywords.html'));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      return parser.getSimpleMangaInfoFromSearch(response.body)..forEach((manga) {
        manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
        manga.sourceKey = _source.key;
      });
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }

  }

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  MangaSource get mangaSource => _source;

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    Response response;
    try {
      response = await  MaxgaHttpUtils.retryRequest(requestBuilder: () => http.get('${_source.domain}rank/?page=${page + 1}&ajax=1&order=1'));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      return parser.getSimpleMangaInfoListFromUpdatePage(response.body)..forEach((manga) {
        manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
        manga.sourceKey = _source.key;
      });
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }
  }

}