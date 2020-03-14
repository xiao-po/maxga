import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/dialog/dialog.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';

enum MangaListTileMenuOption {
  read,
  collect,
  cancelCollect,
  shareLink,
  shareCoverImage,
  searchAuthor
}

typedef _OnSelectMenuOption = void Function(MangaListTileMenuOption option);

class MangaListTileMenuDialog extends StatelessWidget {
  final _OnSelectMenuOption onSelect;
  final SimpleMangaInfo manga;

  const MangaListTileMenuDialog({Key key, this.onSelect, this.manga})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const optionTextStyle = const TextStyle(fontSize: 18);
    return OptionDialog(
      title: manga.title,
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.chrome_reader_mode),
            title: const Text(
              '阅读漫画',
              style: optionTextStyle,
            ),
            onTap: () => onSelect(MangaListTileMenuOption.read)),
//        if (!manga.collected)
//          ListTile(
//              onTap: () => onSelect(MangaListTileMenuOption.collect),
//              leading: Icon(Icons.favorite),
//              title: const Text(
//                '收藏漫画',
//                style: optionTextStyle,
//              )),
//        if (manga.collected)
//          ListTile(
//              onTap: () => onSelect(MangaListTileMenuOption.collect),
//              leading: Icon(Icons.favorite_border),
//              title: const Text(
//                '取消收藏',
//                style: optionTextStyle,
//              )),
        ListTile(
            onTap: () => onSelect(MangaListTileMenuOption.searchAuthor),
            leading: Icon(Icons.search),
            title: const Text('搜索作者其他漫画', style: optionTextStyle)),
        ListTile(
            onTap: () => onSelect(MangaListTileMenuOption.shareCoverImage),
            leading: Icon(Icons.share),
            title: const Text('分享封面', style: optionTextStyle)),
        ListTile(
            onTap: () => onSelect(MangaListTileMenuOption.shareLink),
            leading: Icon(Icons.share),
            title: const Text('分享链接', style: optionTextStyle)),
      ],
    );
  }
}
