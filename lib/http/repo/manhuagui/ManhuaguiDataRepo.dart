import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuagui/crypto/ManhuaguiCrypto.dart';
import 'package:maxga/http/repo/manhuagui/parser/ManhuaguiHtmlParser.dart';
import 'package:maxga/http/utils/MaxgaHttpUtils.dart';
import 'package:maxga/model/manga/Manga.dart';
import 'package:maxga/model/manga/MangaSource.dart';

final ManhuaguiMangaSource = MangaSource(
    name: '漫画柜',
    key: 'manhuagui',
    domain: 'https://m.manhuagui.com/',
    iconUrl: 'https://m.manhuagui.com/favicon.ico',
    headers: {'Referer': 'https://m.manhuagui.com/'});

class ManhuaguiDataRepo extends MaxgaDataHttpRepo {
  MangaSource _source = ManhuaguiMangaSource;
  ManhuaguiHtmlParser parser = ManhuaguiHtmlParser.getInstance();
  MaxgaHttpUtils _httpUtils = MaxgaHttpUtils(ManhuaguiMangaSource);

  @override
  Future<List<String>> getChapterImageList(String url) async {
    return _httpUtils.requestApi<List<String>>('$url',
        parser: (res) =>
            ManhuaguiCrypto.decrypt(parser.getEncryptImageString(res.data))
                .map((url) => 'https://i.hamreus.com$url')
                .toList(growable: false));
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate(int page) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}update/?page=${page + 1}&ajax=1&order=1',
        parser: (res) => parser.getSimpleMangaInfoListFromUpdatePage(res.data)
          ..forEach((manga) {
            manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
            manga.sourceKey = _source.key;
          }));
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    if (url == null) {
      throw MangaHttpError(MangaHttpErrorType.ERROR_PARAM, _source);
    }

    return _httpUtils.requestApi<Manga>(url,
        parser: (res) => parser.getMangaInfo(res.data)
          ..chapterList.forEach((chapter) {
            chapter.url = '${_source.domain}${chapter.url.substring(1)}';
          }));
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        'https://m.manhuagui.com/s/$keywords.html',
        parser: (res) => parser.getSimpleMangaInfoFromSearch(res.data)
          ..forEach((manga) {
            manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
            manga.sourceKey = _source.key;
          }));
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
    return _httpUtils.requestApi<List<SimpleMangaInfo>>(
        '${_source.domain}rank/?page=${page + 1}&ajax=1&order=1',
        parser: (res) => parser.getSimpleMangaInfoListFromUpdatePage(res.data)
          ..forEach((manga) {
            manga.infoUrl = '${_source.domain}${manga.infoUrl.substring(1)}';
            manga.sourceKey = _source.key;
          }));
  }
}
