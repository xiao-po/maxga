import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';

import 'package:maxga/model/manga/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';
import 'constant/HanhanRepoValue.dart';
import 'parser/HanhanHtmlParser.dart';


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
        '${_source.apiDomain}/dfcomiclist_${page + 1}.htm',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) {
            manga.sourceKey = _source.key;
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
        '${_source.apiDomain}/comicsearch/s.aspx?s=$keywords',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) {
            manga.sourceKey = _source.key;
          }));
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/top/a-${page + 1}.htm',
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
          '${_source.apiDomain}/js/ds.js',
          parser: (res) => res.data
              .substring(res.data.indexOf('var sDS = "') + 'var sDS = "'.length,
                  res.data.indexOf('";'))
              .split('|'));
    }
  }

  @override
  Future<String> generateShareLink(Manga manga) {
    return Future.value(manga.infoUrl);
  }
}
