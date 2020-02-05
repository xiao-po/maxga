import 'package:flutter/cupertino.dart';

typedef MangaSourceProxyReplaceCallback = String Function(String url);

class MangaSource {
  final String name;
  final String domain;
  final String apiDomain;
  final String key;
  final String proxyDomain;
  final String iconUrl;

  // todo Proxy 功能搁置
  final MangaSourceProxyReplaceCallback proxyReplaceCallback;

  final Map<String, String> headers;

  const MangaSource(
      {@required this.name,
      @required this.key,
      @required this.iconUrl,
      this.proxyDomain,
      this.headers,
      this.proxyReplaceCallback,
      @required this.apiDomain,
      @required this.domain});
}
