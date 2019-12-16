import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
class MaxgaHttpUtils {
  static Future<Response> retryRequest({int retryCount = 3,@required Future<Response> Function() requestBuilder}) async {
    var retryTimes = 3;
    while(retryTimes > 0) {
      try {
        return requestBuilder();
      } catch(e) {
        retryTimes--;
      }

    }
    if (retryTimes == 0) {
      throw Error();
    }
  }
}