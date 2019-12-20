import 'package:maxga/http/repo/manhuadui/parser/ManhuaduiHtmlParser.dart';

import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';

import '../MaxgaDataHttpRepo.dart';

final ManhuaduiMangaSource = MangaSource(
  name: '漫画堆',
  key: 'manhuadui',
  domain: 'https://www.manhuadui.com',
);

class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = ManhuaduiMangaSource;
  ManhuaduiHtmlParser parser = ManhuaduiHtmlParser.getInstance();
  MaxgaHttpUtils _httpUtils = MaxgaHttpUtils(ManhuaduiMangaSource);

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestApi<List<String>>('${_source.domain}$url',
        parser: (res) => parser.getMangaImageListFromMangaPage(res.data));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/list/riben/update/$page/',
        parser: (res) => parser.getMangaListFromLatestUpdate(res.data)
          ..forEach((manga) => manga.sourceKey = _source.key));
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    return _httpUtils.requestApi<Manga>(url,
        parser: (res) => parser.getMangaFromMangaInfoPage(res.data)
          ..chapterList.forEach((item) => item.comicId = id)
          ..sourceKey = _source.key
          ..id = id
          ..infoUrl = url);
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}/search/?keywords=$keywords',
        parser: (res) => parser.getMangaListFromSearch(res.data)
          ..forEach((item) => item.sourceKey = _source.key));
  }

  @override
  MangaSource get mangaSource => _source;

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    if (page >= 1) {
      return [];
    }

    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        'https://m.manhuadui.com/rank/click/',
        parser: (res) => parser.getMangaListFromRank(res.data)
          ..forEach((el) => el.sourceKey = _source.key));
  }
}
