import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/database/collect-manga-data.repo.dart';
import 'package:maxga/database/collect-status.repo.dart';
import 'package:maxga/route/android/hidden-manga/hidden-manga-page.dart';
import 'package:maxga/route/android/search/search-page.dart';


class MaxgaSearchButton extends StatelessWidget {
  final Color color;

  const MaxgaSearchButton({
    Key key,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: color,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
          return SearchPage();
        }));
      },
    );
  }
}


class MaxgaTestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.details,
      ),
      onPressed: () async {
        var data = await CollectMangaDataRepository.findAllSyncItem();
        print(data.length);
      },
    );
  }
}

