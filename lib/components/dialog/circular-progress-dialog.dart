
import 'package:flutter/material.dart';

class CircularProgressDialog extends StatelessWidget {
  final String tip;
  final bool forbidCancel;

  const CircularProgressDialog({
    Key key, this.tip = "加载中...", this.forbidCancel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var column = Column(
      children: <Widget>[
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child:  Text(
            tip,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                decoration: TextDecoration.none),
          ),
        )
      ],
    );
    var body =  AbsorbPointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Align(
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black38,
            ),
            padding: EdgeInsets.all(20),
            child: column,
          ),
        ),
      ),
    );

    return forbidCancel ? WillPopScope(
      onWillPop: () async => false,
      child: body,
    ) : body ;
  }
}
