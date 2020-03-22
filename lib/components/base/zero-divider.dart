import 'package:flutter/material.dart';

class ZeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(height: 1, color: isDark ? Colors.grey[600] :Colors.grey[400]);
  }


}