import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/http/repo/MaxgaDataHttpRepo.dart';
import 'package:maxga/http/repo/manhuadui/ManhuaduiDataRepo.dart';
import 'package:maxga/service/UpdateService.dart';

import 'http/repo/dmzj/DmzjDataRepo.dart';

class Application {
  static Application _application = Application();

  static Application getInstance() => Application._application;


  MaxgaDataHttpRepo currentDataRepo;

  Application() {
    print('application init');
    currentDataRepo = ManhuaduiDataRepo();
    UpdateService.testClearData();
  }


  changeDataRepo() {
    currentDataRepo = ManhuaduiDataRepo();
  }


}
