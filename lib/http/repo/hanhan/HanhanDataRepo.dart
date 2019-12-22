import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';

import 'package:maxga/model/manga/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';
import 'parser/HanhanHtmlParser.dart';

// ignore: non_constant_identifier_names
final HanhanMangaSource = MangaSource(
    name: '汗汗漫画',
    key: 'hanhan',
    proxyDomain: 'http://hanhan.xiaopo.moe',
    domain: 'http://hanhan.xiaopo.moe',
    headers: {
      'Accept-Encoding': 'gzip, deflate',
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
    });

class HanhanDateRepo extends MaxgaDataHttpRepo {
  MangaSource _source = HanhanMangaSource;
  MaxgaHttpUtils _httpUtils = MaxgaHttpUtils(HanhanMangaSource);

  List<String> _imageServerUrl;

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
            manga.infoUrl = _source.domain + manga.infoUrl;
          }));
  }

  @override
  Future<Manga> getMangaInfo(String url) async {
    await this.initRepo();
    return _httpUtils.requestApi<Manga>(url,
        parser: (res) =>
            parser.getMangaFromInfoPate(res.data)..infoUrl = url);
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/comicsearch/s.aspx?s=$keywords',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) {
            manga.sourceKey = _source.key;
            manga.infoUrl = _source.domain + manga.infoUrl;
          }));
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

  Future<void> initRepo() async {
    if (_imageServerUrl == null) {
      _imageServerUrl = await _httpUtils.requestApi<List<String>>(
          '${_source.domain}/js/ds.js',
          parser: (res) => res.data
              .substring(res.data.indexOf('var sDS = "') + 'var sDS = "'.length,
                  res.data.indexOf('";'))
              .split('|'));
    }
  }
}
