
import 'package:flutter/material.dart';

import '../reset-password-page.dart';

class ResetPasswordButton extends StatelessWidget {
  const ResetPasswordButton({
    Key key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return FlatButton(
      onPressed: () => toResetPassword(context),
      child: Text(
        '忘记密码?',
        style: TextStyle(fontSize: 14, color: theme.accentColor),
      ),
    );
  }

  toResetPassword(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResetPasswordPage(),
    ));
  }

}