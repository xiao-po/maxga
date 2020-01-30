import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/database/readMangaStatus.repo.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/search/search-page.dart';
import 'package:maxga/service/MangaReadStorage.service.dart';
import 'package:provider/provider.dart';

class MaxgaSearchButton extends StatelessWidget {
  final Color color;

  const MaxgaSearchButton({
    Key key,
    this.color = Colors.white,
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

class MaxgaDebuggerDeleteCacheButton extends StatelessWidget {
  final Color color;

  const MaxgaDebuggerDeleteCacheButton({
    Key key,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: color,
      ),
      onPressed: () async {
        await Future.wait([
          MangaStorageService.clearStatus(),
          Provider.of<HistoryProvider>(context).clearHistory()
        ]);
        Scaffold.of(context).showSnackBar(SnackBar(content: const Text('删除完毕')));

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
        final value = await MangaReadStatusRepository.findAll();
        print(value.length);
      },
    );
  }
}
