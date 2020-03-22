import 'package:dio/dio.dart';
import 'package:maxga/constant/setting-value.dart';
import 'package:maxga/http/repo/dmzj/model/dmzj-manga-info.dart';
import 'package:maxga/http/repo/hanmanjia/hanmanjia-data-repo.dart';
import 'package:maxga/provider/public/setting-provider.dart';
import 'package:maxga/service/maxga-server.service.dart';

import 'http/repo/dmzj/dmzj-data-repo.dart';
import 'http/repo/hanhan/hanhan-data-repo.dart';
import 'http/repo/manhuadui/manhuadui-data-repo.dart';
import 'http/repo/manhuagui/manhuagui-data-repo.dart';
import 'http/repo/maxga-data-http-repo.dart';
import 'model/manga/manga-source.dart';

class MangaRepoPool {
  Map<String, MaxgaDataHttpRepo> _map = {};
  Map<String, MangaSource> _mangaSourceMap = {};
  Dio _dio = Dio(BaseOptions(
    connectTimeout: 15000,
  ));

  void changeTimeoutLimit(int value) {
    this._dio = Dio(BaseOptions(
      connectTimeout: value,
    ));
  }

  List<MaxgaDataHttpRepo> get allDataRepo => _getAllRepo();

  List<MangaSource> get allDataSource => _getAllSource();

  Dio get dio => _dio;

  static MangaRepoPool _application = MangaRepoPool();

  static MangaRepoPool getInstance() => MangaRepoPool._application;

  MangaRepoPool() {
    print('pool init');
    final manhuaduiDataRepo = ManhuaduiDataRepo();
    final dmzjDataRepo = DmzjDataRepo(
      beforeInfoParse: _beforeDmzjInfoParse,
    );
    final hanhanDateRepo = HanhanDateRepo();
    final manhuaguiDateRepo = ManhuaguiDataRepo();
    final hanmanjiaDataRepo = HanmanjiaDataRepo();
    registryRepo(dmzjDataRepo);
    registryRepo(hanhanDateRepo);
    registryRepo(manhuaduiDataRepo);
    registryRepo(manhuaguiDateRepo);
    registryRepo(hanmanjiaDataRepo);
  }

  registryRepo(MaxgaDataHttpRepo repo) {
    _mangaSourceMap[repo.mangaSource.key] = repo.mangaSource;
    _map[repo.mangaSource.key] = repo;
  }

  MaxgaDataHttpRepo getRepo({MangaSource source, String key}) {
    if (key != null) {
      return _map[key];
    }

    if (source != null) {
      return _map[source.key];
    }

    throw Error();
  }

  List<MaxgaDataHttpRepo> _getAllRepo() {
    return _map.values.toList(growable: false);
  }

  List<MangaSource> _getAllSource() {
    return _mangaSourceMap.values.toList(growable: false);
  }

  MaxgaDataHttpRepo getDataRepo(String key) {
    return _map[key];
  }

  MangaSource getMangaSourceByKey(String key) {
    return _mangaSourceMap[key];
  }

  _beforeDmzjInfoParse(DmzjMangaInfo mangaInfo) {
    if (SettingProvider.getInstance()
            .getItemValue(MaxgaSettingItemType.autoReportDmzjHiddenManga) ==
        '0') {
      return null;
    }
    if (mangaInfo.isLock == 1 || mangaInfo.hidden == 1) {
      MaxgaServerService.reportDmzjManga(mangaInfo.id);
    }
  }
}
