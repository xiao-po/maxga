import 'package:flutter/cupertino.dart';
import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/route/android/error-page/error-page.dart';

class MangaSourceViewerErrorPage extends StatelessWidget {
  final MangaHttpErrorType errorType;
  final MangaSource source;
  final VoidCallback onTap;

  MangaSourceViewerErrorPage({this.errorType, this.source, this.onTap});

  @override
  Widget build(BuildContext context) {
    switch (this.errorType) {
      case MangaHttpErrorType.NULL_PARAM:
      case MangaHttpErrorType.ERROR_PARAM:
        return ErrorPage('${source.name}接口参数错误，暂时无法提供服务\n'
            '请等待更新或者联系作者');
      case MangaHttpErrorType.RESPONSE_ERROR:
        return ErrorPage(
          '${source.name}接口请求失败，点击重试',
          onTap: this.onTap,
        );
      case MangaHttpErrorType.CONNECT_TIMEOUT:
        return ErrorPage(
          '${source.name}接口请求超时，点击重试',
          onTap: this.onTap,
        );
      case MangaHttpErrorType.PARSE_ERROR:
        return ErrorPage(
          '${source.name}接口解析失败，暂时无法提供服务\n'
              '请等待更新或者联系作者',
          onTap: this.onTap,
        );
      default:
        return ErrorPage('未知错误，暂时无法使用');
    }
  }
}
