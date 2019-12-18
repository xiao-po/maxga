import 'package:http/http.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';

import 'package:maxga/model/manga/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';
import 'parser/HanhanHtmlParser.dart';

final HanhanMangaSource = MangaSource(
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
    });

class HanhanDateRepo extends MaxgaDataHttpRepo {
  MangaSource _source = HanhanMangaSource;
  MaxgaHttpUtils _httpUtils = MaxgaHttpUtils(HanhanMangaSource);

  List<String> _imageServerUrl = [];

  HanhanDateRepo() {
    this.initRepo();
  }

  HanhanHtmlParser parser = HanhanHtmlParser.getInstance();

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestApi<List<String>>(url,
        parser: (res) => parser.getChapterImageList(res.data, _imageServerUrl));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate([int page = 1]) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/dfcomiclist_${page + 1}.htm',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) {
            manga.sourceKey = _source.key;
          }));
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    return _httpUtils.requestApi<Manga>('${_source.domain}/comic/18$id/',
        parser: (res) =>
            parser.getMangaFromInfoPate(res.data)..sourceKey = _source.key);
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/comicsearch/s.aspx?s=$keywords',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) => manga.sourceKey = _source.key));
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/top/a-${page + 1}.htm',
        parser: (res) => parser.getMangaListFromRank(res.data)
          ..forEach((manga) => manga.sourceKey = _source.key));
  }

  @override
  Future<List<String>> getSuggestion(String words) {
    return null;
  }

  @override
  MangaSource get mangaSource => _source;

  void initRepo() async {
    _imageServerUrl = await _httpUtils.requestApi<List<String>>(
        '${_source.domain}/js/ds.js',
        parser: (res) => res.data
            .substring(res.data.indexOf('var sDS = "') + 'var sDS = "'.length,
                res.data.indexOf('";'))
            .split('|'));
  }
}
