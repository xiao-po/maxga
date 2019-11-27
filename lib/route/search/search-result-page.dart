import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';

import '../../Application.dart';

class SearchResultPage extends StatefulWidget {
  final String name = 'search_result';
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
                  cover: MangaCoverImage(
                    source: item.source,
                    url: item.coverImgUrl,
                    tagPrefix: widget.name,
                  ),
                  onTap: () => this.goMangaInfoPage(item),
                ))
            .toList());
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        coverImageBuilder: (context) => MangaCoverImage(
          source: item.source,
          url: item.coverImgUrl,
          tagPrefix: widget.name,
          fit: BoxFit.cover,
        ),
        manga: item,
      );
    }));
  }
}
