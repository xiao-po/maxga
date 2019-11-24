import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'package:maxga/model/MangaSource.dart';
import 'package:maxga/service/UpdateService.dart';

import 'http/repo/dmzj/DmzjDataRepo.dart';

class Application {
  static Application _application = Application();

  static Application getInstance() => Application._application;

  MangaRepoPool _mangaRepoPool = MangaRepoPool();
  MangaSource _currentSource;

  Application() {
    final manhuaduiDataRepo = ManhuaduiDataRepo();
    final dmzjDataRepo = DmzjDataRepo();
    _mangaRepoPool.registryRepo(manhuaduiDataRepo);
    _mangaRepoPool.registryRepo(dmzjDataRepo);
    _currentSource = dmzjDataRepo.mangaSource;
  }

  void changeMangaSource(MangaSource source) {
    _currentSource = source;
  }

  MaxgaDataHttpRepo getMangaSource({String key}) {
    if (key != null) {
      return _mangaRepoPool.getRepo(key: key);
    } else {
      return _mangaRepoPool.getRepo(source: _currentSource);
    }
  }

  get allDataRepo => _mangaRepoPool.getAllRepo();
  get allDataSource => _mangaRepoPool.getAllSource();



}


class MangaRepoPool {
  Map<String, MaxgaDataHttpRepo> _map = {};

  registryRepo(MaxgaDataHttpRepo repo) {
    _map.addAll({repo.mangaSource.key: repo});
  }

  getRepo({MangaSource source, String key}) {
    if (key != null) {
      return _map[key];
    }

    if (source != null) {
      return _map[source.key];
    }

    throw Error();
  }


  List<MaxgaDataHttpRepo> getAllRepo() {
    return _map.values;
  }

  List<MangaSource> getAllSource() {
    return _map.values.map((el) => el.mangaSource).toList(growable: false);
  }
}
