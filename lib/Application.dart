import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Application {
  static Application _application = Application();

  static getInstance() => Application._application;


  Application() {
    print('application init');
  }
}
