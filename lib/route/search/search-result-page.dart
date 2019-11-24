import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';

import '../../Application.dart';

class SearchResultPage extends StatefulWidget {
  final String keyword;

  const SearchResultPage({Key key, this.keyword}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<SimpleMangaInfo> mangaResultList = [];

  @override
  void initState() {
    super.initState();
    this.getResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
        appBar: AppBar(
          title: Text(widget.keyword),
        ),
        body: mangaResultList.length == 0 ? _loadingPage() : _buildMangaList());
  }

  void getResult() async {
    Application application = Application.getInstance();
    mangaResultList = await application.getMangaSource().getSearchManga(widget.keyword);
    print(mangaResultList.length);
    setState(() {});
  }

  Widget _loadingPage() {
    return Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMangaList() {
    return ListView(
        children: mangaResultList
            .map((item) => MangaCard(
                  manga: item,
                  cover: _buildCachedNetworkImage(item),
                  onTap: () => this.goMangaInfoPage(item),
                ))
            .toList());
  }

  Widget _buildCachedNetworkImage(SimpleMangaInfo item) {
    return Hero(
      tag: 'search_page_${item.coverImgUrl}',
      child: CachedNetworkImage(
          imageUrl: item.coverImgUrl,
          placeholder: (context, url) =>
              CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        coverImageBuilder: (context) => _buildCachedNetworkImage(item),
        manga: item,
      );
    }));
  }
}
