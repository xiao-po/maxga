

import 'package:flutter/material.dart';

enum TapPosition { left, right, center }

class TapAreaRecognizeUtil {
  static TapPosition recognizeTapArea(TapUpDetails details, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    var position;
    if (details.localPosition.dx / width > 0.33 &&
        details.localPosition.dx / width < 0.66) {
      position = TapPosition.center;
    } else if (details.localPosition.dx / width < 0.33) {
      position = TapPosition.left;
    } else if (details.localPosition.dx / width > 0.66) {
      position = TapPosition.right;
    }
    return position;
  }

}