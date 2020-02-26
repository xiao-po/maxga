
import 'form-item.dart';

class MaxgaValidator {

  static String passwordLengthValidator(FormItem item) {
    final value = item.value;
    if (value.length >= 6  && value.length <= 20) {
      return null;
    } else {
      return "密码不得少于 6 位，不能多于 20 位";
    }
  }

  static String checkSpaceExist(FormItem item) {
    final value = item.value;
    return value.indexOf(" ") != -1 ? '不允许输入空格' : null;
  }

  static String emptyValidator(FormItem item) {
    return item.isEmpty ? "请填写" : null;
  }

  static String emailValidator(FormItem item) {
    RegExp regExp = RegExp('^[a-zA-Z0-9-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)+\$');
    if(regExp.hasMatch(item.value)) {
      return null;
    } else {
      return "邮箱格式错误";
    }
  }
}
