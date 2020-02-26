import 'package:maxga/model/manga/manga-source.dart';
const HanhanMangaSourceKey = 'hanhan';
const HanhanMangaSource = const MangaSource(
    name: '汗汗漫画',
    key: HanhanMangaSourceKey,
    domain: 'http://bbssoo.com',
    apiDomain: 'http://bbssoo.com',
    proxyDomain: 'http://hanhan.xiaopo.moe',
    iconUrl: 'http://hanhan.xiaopo.moe/favicon.ico',
    headers: {
      'Accept-encoding-': 'gzip, deflate',
      'accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'user-agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
    });