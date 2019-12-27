import 'package:flutter/cupertino.dart';

typedef MangaSourceProxyReplaceCallback = String Function(String url);



class MangaSource {
  String name;
  String domain;
  String key;
  String proxyDomain;
  String iconUrl;
  // todo Proxy 功能搁置
  MangaSourceProxyReplaceCallback proxyReplaceCallback;

  Map<String, String> headers;


  MangaSource(
      {@required this.name,
      @required this.key,
      @required  this.iconUrl,
        this.proxyDomain,
      this.headers,
      proxyReplaceCallback,
      @required this.domain});
}
