

import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final String message;
  ErrorPage(this.message, {this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: const Color(0xffcccccc)),
          ),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

}
