import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/http/repo/hanmanjia/parser/hanmanjia-html-parser.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/http/repo/utils/manga-http-utils.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

import 'constants/hanmanjia-repo-value.dart';

class HanmanjiaDataRepo implements MaxgaDataHttpRepo {

  HanmanjiaHtmlParser parser = HanmanjiaHtmlParser.getInstance();
  MangaHttpUtils _httpUtils = MangaHttpUtils(HanmanjiaMangaSource);

  @override
  Future<String> generateShareLink(MangaBase manga) {
    return Future.value(manga.infoUrl);
  }

  @override
  Future<List<String>> getChapterImageList(String url) {
    return _httpUtils.requestMangaSourceApi<List<String>>(
      url,
      parser: (res) => parser
          .getImageListFromChapter(res.data)
          .toList());
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
        '${mangaSource.apiDomain}/booklist?page=${page + 1}',
        parser: (res) => parser
            .getMangaListFromLatestUpdate(res.data)
            .map((manga) => manga.copyWith(sourceKey: mangaSource.key)).toList());
  }

  @override
  Future<Manga> getMangaInfo(String url) {
    return _httpUtils.requestMangaSourceApi<Manga>(
        url,
        parser: (res) => parser
            .getMangaInfo(res.data)
            .copyWith(sourceKey: mangaSource.key, infoUrl:  url));
  }

  @override
  Future<List<SimpleMangaInfo>> getRankedManga(int page) {
    throw MangaRepoError(MangaHttpErrorType.CAN_NOT_PROVIDE, mangaSource);
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) {
    return _httpUtils.requestMangaSourceApi<List<SimpleMangaInfo>>(
      '${mangaSource.domain}/search?keyword=$keywords',
        parser: (res) => parser
            .getMangaListFormSearch(res.data)
            .map((e) => e.copyWith(infoUrl: '${mangaSource.apiDomain}${e.infoUrl}'))
            .toList()
    );
//    throw UnimplementedError();
  }

  @override
  Future<List<String>> getSuggestion(String words) {
    throw MangaRepoError(MangaHttpErrorType.CAN_NOT_PROVIDE, mangaSource);
  }

  @override
  MangaSource get mangaSource => HanmanjiaMangaSource;
}