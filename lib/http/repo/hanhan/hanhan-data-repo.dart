import 'package:maxga/http/repo/utils/manga-http-utils.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

import '../maxga-data-http-repo.dart';
import 'constant/hanhan-repo-value.dart';
import 'parser/hanhan-html-parser.dart';

class HanhanDateRepo extends MaxgaDataHttpRepo {
  MangaSource _source = HanhanMangaSource;
  MangaHttpUtils _httpUtils = MangaHttpUtils(HanhanMangaSource);

  List<String> _imageServerUrl;

  HanhanHtmlParser parser = HanhanHtmlParser.getInstance();

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestMangaSourceApi<List<String>>(url,
        parser: (res) => parser.getChapterImageList(res.data, _imageServerUrl));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate([int page = 1]) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/dfcomiclist_${page + 1}.htm',
        parser: (res) => parser
            .getMangaListFromLatestUpdate(res.data)
            .map((manga) => manga.copyWith(sourceKey: _source.key)));
  }

  @override
  Future<Manga> getMangaInfo(String url) async {
    await this.initRepo();
    return _httpUtils.requestMangaSourceApi<Manga>(url,
        parser: (res) =>
            parser.getMangaFromInfoPate(res.data).copyWith(infoUrl: url));
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/comicsearch/s.aspx?s=$keywords',
        parser: (res) => parser
            .getMangaListFromLatestUpdate(res.data)
            .map((manga) => manga.copyWith(sourceKey: _source.key)).toList());
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}/top/a-${page + 1}.htm',
        parser: (res) => parser
            .getMangaListFromRank(res.data)
            .map((manga) => manga.copyWith(sourceKey: _source.key)));
  }

  @override
  Future<List<String>> getSuggestion(String words) {
    return null;
  }

  @override
  MangaSource get mangaSource => _source;

  Future<void> initRepo() async {
    if (_imageServerUrl == null) {
      _imageServerUrl = await _httpUtils.requestMangaSourceApi<List<String>>(
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
