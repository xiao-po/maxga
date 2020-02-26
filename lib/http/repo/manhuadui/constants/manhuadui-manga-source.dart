import 'package:maxga/model/manga/manga-source.dart';
const ManhuaduiMangaSourceKey = 'manhuadui';
const ManhuaduiMangaSource = const MangaSource(
    name: '漫画堆',
    key: ManhuaduiMangaSourceKey,
    domain: 'https://m.manhuadui.com',
    apiDomain: 'https://m.manhuadui.com',
    iconUrl: 'https://m.manhuadui.com/favicon.ico',
    headers: {
      'referer': 'https://m.manhuadui.com'
    }
);