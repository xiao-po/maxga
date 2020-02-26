import 'package:flutter/cupertino.dart';

typedef MangaSourceProxyReplaceCallback = String Function(String url);

class MangaSource {
  final String name;
  final String domain;
  final String apiDomain;
  final String key;
  final String proxyDomain;
  final String iconUrl;


  final Map<String, String> headers;

  const MangaSource(
      {@required this.name,
      @required this.key,
      @required this.iconUrl,
      this.proxyDomain,
      this.headers,
      @required this.apiDomain,
      @required this.domain});

  replaceUrlToProxy(String url) {
    if (this.proxyDomain != null) {
      return url.replaceFirst(this.apiDomain, this.proxyDomain);
    } else {
      return url;
    }
  }
}
