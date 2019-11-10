import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';

import 'http/repo/dmzj/DmzjDataRepo.dart';

class Application {
  static Application _application = Application();

  static Application getInstance() => Application._application;


  MaxgaDataHttpRepo currentDataRepo;

  Application() {
    print('application init');
    currentDataRepo = DmzjDataRepo();
  }


  changeDataRepo() {
    currentDataRepo = ManhuaduiDataRepo();
  }

}
