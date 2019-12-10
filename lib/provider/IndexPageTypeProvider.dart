import 'dart:async';

import 'package:maxga/base/drawer/menu-item.dart';

import 'base/BaseProvider.dart';

class IndexPageTypeProvider extends BaseProvider {

  MaxgaMenuItemType _type = MaxgaMenuItemType.collect;
  MaxgaMenuItemType get type => _type;

  StreamController streamController = StreamController<MaxgaMenuItemType>()..add(MaxgaMenuItemType.collect);

  static IndexPageTypeProvider _instance;

  static IndexPageTypeProvider getInstance() {
    if (_instance == null) {
      _instance =  IndexPageTypeProvider();
    }
    return _instance;
  }

  changeIndexPageType(MaxgaMenuItemType type) {
    switch (type) {
      case MaxgaMenuItemType.collect:
      case MaxgaMenuItemType.mangaSourceViewer:
        if (type != _type) {
          _type = type;
          notifyListeners();
        }
        break;
      case MaxgaMenuItemType.history:
      case MaxgaMenuItemType.setting:
      case MaxgaMenuItemType.about:
        throw Error();
    }
    streamController.add(_type);
  }

  @override
  void dispose() {
    super.dispose();
    streamController.close();
  }

}
