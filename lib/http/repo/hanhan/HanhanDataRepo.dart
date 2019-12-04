import 'package:maxga/model/Manga.dart';

import 'package:maxga/model/MangaSource.dart';
import 'package:http/http.dart' as http;

import '../MaxgaDataHttpRepo.dart';
import 'parser/HanhanHtmlParser.dart';

const HanhanHttpHeader = {
  'Accept-Encoding': 'gzip, deflate',
  'accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
  'user-agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36'
};

class HanhanDateRepo extends MaxgaDataHttpRepo {
  MangaSource _source = MangaSource(
    name: '汗汗漫画',
    key: 'hanhan',
    iconUrl: 'http://hanhan.xiaopo.moe/favicon.ico',
    domain: 'http://hanhan.xiaopo.moe',
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
      headers: HanhanHttpHeader,
    );
    return parser.getChapterImageList(response.body, _imageServerUrl);
  }

  @override
  Future<List<SimpleMangaInfo>> getLatestUpdate([int page = 1]) async {
    final response = await http.get(
      '${_source.domain}/dfcomiclist_$page.htm',
      headers: HanhanHttpHeader,
    );
    final list = parser.getMangaListFromLatestUpdate(response.body)
      ..forEach((manga) {
        manga.source = _source;
      });
    return list;
  }

  @override
  Future<Manga> getMangaInfo({int id, String url}) async {
    var response;
    if (id != null) {
      response = await http.get(
        '${_source.domain}/comic/18$id/',
        headers: HanhanHttpHeader,
      );
    } else if (url != null) {
      response = await http.get(
        url,
        headers: HanhanHttpHeader,
      );
    } else {
      throw Error();
    }
    final manga = parser.getMangaFromInfoPate(response.body);
    manga.source = _source;
    return manga;
  }

  @override
  Future<List<SimpleMangaInfo>> getSearchManga(String keywords) async {
    var response = await http.get(
      '${_source.domain}/comicsearch/s.aspx?s=$keywords',
      headers: HanhanHttpHeader,
    );
    final mangaList = parser.getMangaListFromLatestUpdate(response.body);
    mangaList.forEach((manga) => manga.source = _source);
    return mangaList;
  }

  @override
  Future<List<String>> getSuggestion(String words) {
    // TODO: implement getSuggestion
    return null;
  }

  @override
  MangaSource get mangaSource => _source;

  void initRepo() async {
    final dsResponse = await http.get('${_source.domain}/js/ds.js');
    final dsBody = dsResponse.body;
    _imageServerUrl = dsBody
        .substring(dsBody.indexOf('var sDS = "') + 'var sDS = "'.length,
            dsBody.indexOf('";'))
        .split('|');
  }
}
