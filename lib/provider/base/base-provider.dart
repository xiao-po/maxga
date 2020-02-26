import 'package:flutter/cupertino.dart';

abstract class BaseProvider with ChangeNotifier {
  bool _disposed = false;


  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}