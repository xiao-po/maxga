import 'package:maxga/model/manga/MangaSource.dart';
const DmzjMangaSourceKey = 'dmzj';
const DmzjMangaSource = const MangaSource(
    name: '动漫之家',
    key: DmzjMangaSourceKey,
    domain: 'https://m.dmzj.com',
    apiDomain: 'https://v3api.dmzj.com',
    iconUrl: 'http://dmzj.com/favicon.ico',
    headers: {
      'referer': 'http://m.dmzj.com/latest.html',
    });
