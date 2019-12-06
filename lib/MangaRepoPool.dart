import 'http/repo/MaxgaDataHttpRepo.dart';
import 'http/repo/dmzj/DmzjDataRepo.dart';
import 'http/repo/hanhan/HanhanDataRepo.dart';
import 'http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'http/repo/manhuagui/ManhuaguiDataRepo.dart';
import 'model/manga/MangaSource.dart';

class MangaRepoPool {
  Map<String, MaxgaDataHttpRepo> _map = {};
  Map<String, MangaSource> _mangaSourceMap = {};
  MangaSource _currentSource;

  void changeMangaSource(MangaSource source) {
    _currentSource = source;
  }

  List<MaxgaDataHttpRepo> get allDataRepo => _getAllRepo();
  List<MangaSource> get allDataSource => _getAllSource();
  MaxgaDataHttpRepo get currentDataRepo => _map[_currentSource.key];
  
  

  static MangaRepoPool _application = MangaRepoPool();
  static MangaRepoPool getInstance() => MangaRepoPool._application;
  
  

  MangaRepoPool() {
    final manhuaduiDataRepo = ManhuaduiDataRepo();
    final dmzjDataRepo = DmzjDataRepo();
    final hanhanDateRepo = HanhanDateRepo();
    final manhuaguiDateRepo = ManhuaguiDataRepo();
    registryRepo(manhuaduiDataRepo);
    registryRepo(manhuaguiDateRepo);
    registryRepo(dmzjDataRepo);
    registryRepo(hanhanDateRepo);
    _currentSource = dmzjDataRepo.mangaSource;
  }

  registryRepo(MaxgaDataHttpRepo repo) {
    _mangaSourceMap[repo.mangaSource.key] = repo.mangaSource;
    _map[repo.mangaSource.key] = repo;
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


  
  
}
