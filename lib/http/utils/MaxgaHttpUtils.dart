import 'package:http/http.dart';
import 'package:maxga/base/error/MaxgaHttpError.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:http/http.dart' as http;

class MaxgaHttpUtils {
  final MangaSource source;

  MaxgaHttpUtils(this.source);

  Future<T> requestApi<T>(String url,
      {T Function(Response response) parser}) async {
    Response response;
    try {
      var retryTimes = 3;
      while (retryTimes > 0) {
        try {
          response = await http.get(url, headers: source.headers);
        } catch (e) {
          retryTimes--;
        }
      }
      if (retryTimes == 0) {
        throw Error();
      }
    } catch (e) {
      throw MangaHttpResponseError(source);
    }
    try {
      return parser(response);
    } catch (e) {
      throw MangaHttpConvertError(source);
    }
  }
}
