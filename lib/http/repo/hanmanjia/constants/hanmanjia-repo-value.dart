import 'package:maxga/model/manga/manga-source.dart';

const HanmanjiaMangaSourceKey = 'hanmanjia';
const HanmanjiaMangaSource = const MangaSource(
    name: '韩漫家',
    key: HanmanjiaMangaSourceKey,
    domain: 'https://www.hanmanjia.com/',
    apiDomain: 'https://www.hanmanjia.com/',
    iconUrl: 'https://www.hanmanjia.com/favicon.ico',
    headers: {
      'Accept-encoding-': 'gzip, deflate',
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
      'user-agent':
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Mobile Safari/537.36',
    });
