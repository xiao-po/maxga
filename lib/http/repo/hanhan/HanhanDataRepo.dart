import 'package:http/http.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';

import 'package:maxga/model/manga/MangaSource.dart';
import 'package:http/http.dart' as http;

import '../MaxgaDataHttpRepo.dart';
import 'parser/HanhanHtmlParser.dart';


class HanhanDateRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '汗汗漫画',
    key: 'hanhan',
    iconUrl: 'http://hanhan.xiaopo.moe/favicon.ico',
    domain: 'http://hanhan.xiaopo.moe',
    headers: {
      'Accept-Encoding': 'gzip, deflate',
      'accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'user-agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
      'cookies':
      'ASP.NET_SessionId=twmkry55pznarv55tgzhzq45; ViewCtTxt=36219*370057*%u5723%u5251%u9171%u4E0D%u80FD%u8131*%u5723%u5251%u9171%u4E0D%u80FD%u8131%20039%u96C6*%5E36219*367967*%u5723%u5251%u9171%u4E0D%u80FD%u8131*%u5723%u5251%u9171%u4E0D%u80FD%u8131%20037%u96C6*%5E36219*369087*%u5723%u5251%u9171%u4E0D%u80FD%u8131*%u5723%u5251%u9171%u4E0D%u80FD%u8131%20038%u96C6*'
    }
  );

  List<String> _imageServerUrl = [];

  HanhanDateRepo() {
    this.initRepo();
  }

  HanhanHtmlParser parser = HanhanHtmlParser.getInstance();

  @override
  Future<List<String>> getChapterImageList(String url) async {
    final response = await http.get(
      url,
      headers: _source.headers,
    );
    return parser.getChapterImageList(response.body, _imageServerUrl);
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate([int page = 1]) async {
    Response response;
    try{
      response = await MaxgaHttpUtils.retryRequest(
          requestBuilder: () => http.get(
            '${_source.domain}/dfcomiclist_${page + 1}.htm',
            headers: _source.headers,
          ));
    }catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      final list = parser.getMangaListFromLatestUpdate(response.body)
        ..forEach((manga) {
          manga.sourceKey = _source.key;
        });
      return list;
    } catch (e) {
      throw MangaHttpApiParserError(_source);
    }
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    Response response;
    try{
      response = await MaxgaHttpUtils.retryRequest(
          requestBuilder: () {
            if (id != null) {
              return http.get(
                '${_source.domain}/comic/18$id/',
                headers: _source.headers,
              );
            } else if (url != null) {
              return http.get(
                url,
                headers: _source.headers,
              );
            } else {
              throw MangaHttpNullParamError(_source);
            }
          }
      );
    }catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      final manga = parser.getMangaFromInfoPate(response.body);
      manga.sourceKey = _source.key;
      return manga;
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    var response;
    try {
      response = await MaxgaHttpUtils.retryRequest(requestBuilder: () =>  http.get(
        '${_source.domain}/comicsearch/s.aspx?s=$keywords',
        headers: _source.headers,
      ));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      final mangaList = parser.getMangaListFromLatestUpdate(response.body);
      mangaList.forEach((manga) => manga.sourceKey = _source.key);
      return mangaList;
    } catch(e) {
      throw MangaHttpApiParserError(_source);
    }
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    var response;
    try {
      response = await MaxgaHttpUtils.retryRequest(requestBuilder: () =>   http.get(
        '${_source.domain}/top/a-${page + 1}.htm',
        headers: _source.headers,
      ));
    } catch(e) {
      throw MangaHttpResponseError(_source);
    }
    try {
      final mangaList = parser.getMangaListFromRank(response.body);
      mangaList.forEach((manga) => manga.sourceKey = _source.key);
      return mangaList;
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

  void initRepo() async {
    var retryTimes = 3;
    while (retryTimes > 0) {
      try {
        final dsResponse = await http.get('${_source.domain}/js/ds.js');
        final dsBody = dsResponse.body;
        _imageServerUrl = dsBody
            .substring(dsBody.indexOf('var sDS = "') + 'var sDS = "'.length,
                dsBody.indexOf('";'))
            .split('|');
      } catch (e) {
        retryTimes--;
      }
    }
  }
}
