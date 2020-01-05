
import 'package:maxga/model/manga/MangaSource.dart';

// ignore: non_constant_identifier_names
final HanhanMangaSource = MangaSource(
    name: '汗汗漫画',
    key: 'hanhan',
    domain: 'http://hanhan.xiaopo.moe',
    apiDomain: 'http://hanhan.xiaopo.moe',
    proxyDomain: 'http://hanhan.xiaopo.moe',
    iconUrl: 'http://hanhan.xiaopo.moe/favicon.ico',
    headers: {
      'Accept-Encoding': 'gzip, deflate',
      'accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'user-agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36',
    });