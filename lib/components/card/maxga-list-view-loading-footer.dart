import 'package:flutter/material.dart';

class MaxgaListViewLoadingFooter extends StatelessWidget {
  const MaxgaListViewLoadingFooter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
