import 'package:maxga/http/repo/manhuagui/crypto/manhuagui-crypto.dart';
import 'package:maxga/http/repo/manhuagui/parser/manhuagui-html-parser.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/http/repo/utils/manga-http-utils.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/manga.dart';

import 'constants/manhuagui-manga-source.dart';

class ManhuaguiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = ManhuaguiMangaSource;
  ManhuaguiHtmlParser parser = ManhuaguiHtmlParser.getInstance();
  MangaHttpUtils _httpUtils = MangaHttpUtils(ManhuaguiMangaSource);

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestMangaSourceApi<List<String>>('$url',
        parser: (res) =>
            ManhuaguiCrypto.decrypt(parser.getEncryptImageString(res.data))
                .map((url) => 'https://i.hamreus.com$url')
                .toList(growable: false));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}update/?page=${page + 1}&ajax=1&order=1',
        parser: (res) => parser
            .getSimpleMangaInfoListFromUpdatePage(res.data)
            .map((manga) => manga.copyWith(
                infoUrl: '${_source.apiDomain}${manga.infoUrl.substring(1)}',
                sourceKey: _source.key)));
  }

  @override
  Future<Manga> getMangaInfo(String url) async {
    return _httpUtils.requestMangaSourceApi<Manga>(url,
        parser: (res) => parser.getMangaInfo(res.data).copyWith(
              infoUrl: url,
            )..chapterList.forEach((chapter) {
                chapter.url = '${_source.apiDomain}${chapter.url.substring(1)}';
              }));
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        'https://m.manhuagui.com/s/$keywords.html',
        parser: (res) => parser.getSimpleMangaInfoFromSearch(res.data).map(
            (manga) => manga.copyWith(
                infoUrl: '${_source.apiDomain}${manga.infoUrl.substring(1)}',
                sourceKey: _source.key)));
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
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${_source.apiDomain}rank/?page=${page + 1}&ajax=1&order=1',
        parser: (res) => parser
            .getSimpleMangaInfoListFromUpdatePage(res.data)
            .map((manga) => manga.copyWith(
                infoUrl: '${_source.apiDomain}${manga.infoUrl.substring(1)}',
                sourceKey: _source.key)));
  }

  @override
  Future<String> generateShareLink(MangaBase manga) {
    return Future.value(manga.infoUrl);
  }
}
