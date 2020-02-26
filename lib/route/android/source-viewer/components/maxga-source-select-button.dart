import 'package:flutter/material.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/manga-source.dart';

typedef OnMangaSelected = void Function(MangaSource source);

class MaxgaSourceSelectButton extends StatelessWidget {
  final OnMangaSelected onSelect;
  final _sourceList = MangaRepoPool.getInstance()?.allDataSource;

  MaxgaSourceSelectButton({Key key, @required this.onSelect}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MangaSource>(
      itemBuilder: (context) => _sourceList
          .map((el) => PopupMenuItem(
        value: el,
        child: Text(el.name),
      ))
          .toList(),
      onSelected: (value) => this.onSelect(value),
    );
  }

}
