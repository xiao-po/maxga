import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:maxga/MangaRepoPool.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/components/MangaGridItem.dart';
import 'package:maxga/components/MaxgaButton.dart';
import 'package:maxga/model/maxga/ReadMangaStatus.dart';
import 'package:maxga/provider/CollectionProvider.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:provider/provider.dart';


class CollectionPage extends StatefulWidget {
  final String name = 'collection-page';

  @override
  State<StatefulWidget> createState() => CollectionPageState();
}

class CollectionPageState extends State<CollectionPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppBar(
              title: const Text('收藏'),
              leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer()),
              actions: <Widget>[
                MaxgaSearchButton(),
              ],
            ),
            Expanded(
              child: buildBody(),
            )
          ],
        ));
  }

  Widget buildBody() {
    CollectionProvider provider = Provider.of<CollectionProvider>(context);
    if (!provider.loadOver) {
      return Container();
    } else if (provider.loadOver && provider.isEmpty) {
      return ErrorPage('您没有收藏的漫画');
    } else {
      double screenWith = MediaQuery.of(context).size.width;
      double itemMaxWidth = 140;
      double radio = screenWith / itemMaxWidth;
      final double itemWidth = radio.floor() > 3 ? itemMaxWidth : screenWith / 3;
      final double height = (itemWidth + 20) / 13 * 15 + 40;
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: GridView.count(
            crossAxisCount: radio.floor() > 3 ? radio.floor() : 3,
            childAspectRatio: itemWidth / height,
            children: provider.collectionMangaList
                .map(
                  (el) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () => this.startRead(el),
                      child: MangaGridItem(
                        manga: el,
                        tagPrefix: widget.name,
                        source: MangaRepoPool.getInstance()
                            .getMangaSourceByKey(el.sourceKey),
                      ))),
            )
                .toList(growable: false),
          ));
    }
  }

  startRead(ReadMangaStatus item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MangaInfoPage.fromCollection(
          coverImageBuilder: (context) => MangaCoverImage(
                source: MangaRepoPool.getInstance()
                    .getMangaSourceByKey(item.sourceKey),
                url: item.coverImgUrl,
                tagPrefix: widget.name,
                fit: BoxFit.cover,

              ),
          manga: item,);
    }));
  }

  refreshCollections() {}
}
