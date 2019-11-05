import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/http/repo/dmzj/DmzjDataRepo.dart';
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
  List<Manga> mangaResultList = [];

  @override
  void initState() {
    super.initState();
    this.getResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.keyword),
        ),
        body: mangaResultList.length == 0 ? _loadingPage() : _buildMangaList());
  }

  void getResult() async {
    Application application = Application.getInstance();
    mangaResultList = await application.currentDataRepo.getSearchManga(widget.keyword);
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

  CachedNetworkImage _buildCachedNetworkImage(Manga item) {
    return CachedNetworkImage(
        imageUrl: item.coverImgUrl,
        placeholder: (context, url) =>
            CircularProgressIndicator(strokeWidth: 2));
  }

  goMangaInfoPage(Manga item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        url: item.infoUrl,
        id: item.id,
      );
    }));
  }
}
