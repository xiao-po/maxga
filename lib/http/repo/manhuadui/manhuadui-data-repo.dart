import 'package:maxga/http/repo/manhuadui/parser/manhuadui-html-parser.dart';
import 'package:maxga/http/repo/utils/manga-http-utils.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

import '../maxga-data-http-repo.dart';
import 'constants/manhuadui-manga-source.dart';

class ManhuaduiDataRepo extends MaxgaDataHttpRepo {
  ManhuaduiHtmlParser parser = ManhuaduiHtmlParser.getInstance();
  MangaHttpUtils _httpUtils = MangaHttpUtils(ManhuaduiMangaSource);

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestMangaSourceApi<List<String>>(
        '${mangaSource.apiDomain}$url',
        parser: (res) => parser.getMangaImageListFromMangaPage(res.data));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${mangaSource.apiDomain}/update/?page=${page + 1}',
        parser: (res) => parser
            .getMangaListFromLatestUpdate(res.data)
            .map((manga) => manga.copyWith(sourceKey: mangaSource.key)).toList());
  }

  @override
  Future<Manga> getMangaInfo(String url) async {
    return _httpUtils.requestMangaSourceApi<Manga>(url,
        parser: (res) =>
            parser.getMangaFromMangaInfoPage(res.data).copyWith(infoUrl: url));
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${mangaSource.apiDomain}/search/?keywords=$keywords',
        parser: (res) => parser
            .getMangaListFromSearch(res.data)
            .map((manga) => manga.copyWith(sourceKey: mangaSource.key)).toList());
  }

  @override
  MangaSource get mangaSource => ManhuaduiMangaSource;

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) async {
    if (page >= 1) {
      return [];
    }

    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        'https://m.manhuadui.com/rank/click/',
        parser: (res) => parser
            .getMangaListFromRank(res.data)
            .map((manga) => manga.copyWith(sourceKey: mangaSource.key)).toList());
  }

  @override
  Future<String> generateShareLink(MangaBase manga) {
    return Future.value(manga.infoUrl);
  }
}
