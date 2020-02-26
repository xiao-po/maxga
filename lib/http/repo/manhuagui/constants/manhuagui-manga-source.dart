import 'package:maxga/model/manga/manga-source.dart';

const ManhuaguiMangaSourceKey = 'manhuagui';
const ManhuaguiMangaSource = const MangaSource(
    name: '漫画柜',
    key: 'manhuagui',
    domain: 'https://m.manhuagui.com/',
    apiDomain: 'https://m.manhuagui.com/',
    iconUrl: 'https://m.manhuagui.com/favicon.ico',
    headers: {'Referer': 'https://m.manhuagui.com/'});
