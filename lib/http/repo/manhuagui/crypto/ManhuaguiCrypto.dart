import 'dart:convert';

import 'package:lzstring/lzstring.dart';

class ManhuaguiCrypto {
  static test() {
    final encryptString =
        'window["eval"](function(p,a,c,k,e,d){debugger;e=function(c){return(c<a?"":e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!\'\'.replace(/^/,String)){while(c--)d[e(c)]=k[c]||e(c);k=[function(e){return d[e]}];e=function(){return\'\w+\'};c=1;};while(c--)if(k[c])p=p.replace(new RegExp(\'\b\'+e(c)+\'\b\',\'g\'),k[c]);return p;}(\'n.j({"k":4,"l":"g，h","i":"4.2","p":q,"r":"5","m":["o.2.0","6-8.2.0","9.2.0","7.2.0","a.2.0","e.2.0","f-c.3.0","d.3.0","E.3.0","G.2.0"],"H":F,"D":I,"K":"/L/b/J/5/","C":1,"v":"","w":u,"s":t,"A":{"B":"z-x"}}).y();\',48,48,\'O4UwRgDgPlBWEHMoQHZIMwEYAMBOATFIN7xg8DqAv0YKrKgMhGA05oIA6gRumBTytTYJb6gf2pQDsmAXgE0AzkIAcUACKwA+gAkAqpgAu80QEF5AcWkBjADJQQALQMSAlvgDSmgCxh5NtQFFu+AGwB1SQGsnATyEARQA5VTU1FAALbAAhGFEAR3l5cIEENwAFSQBXACUbADFYABt5bHCAMwqjAGFJJQF8CsjQxzVMYrN5HNz0KEBqiMBTJUAuTUAwuUAkxUBLNMBQAMBzI0BzR0AQt0ByTUAV5ShAdP1ABiVRwEYnQGdNQAKDQCfUxcAW6MAZa0AuuUB8VyhIMx0oMwBbBAkAQyUP+7MAE3uKA+LxAUAqZmKICEUAAygBZWQ8TBwpzeABOAFZAi9ZAYdP8oDZMKJRNgbFAdECQcg0SAAG4ASQBRNEbiJhPw2DcJPuxQA9jpvLonigQAAPJRMqCBAAafLUNJADJQZiUUGCdPQMpiOmwGWwmCEGVyqgkligQmKUBefwxFu+Smy0MhKB66BscIZADUBOEUB4am4wR9ikJQS9uKTMNwMQbRPh0NJMGCzCqhJEQACcPcwH9ii8xXwi38hNIKi81RAvpFkEIbEA===\'[\'splic\'](\'|\'),0,{}))';

    var imagePathList = decrypt(encryptString);
  }

  static List<String> decrypt(String str) {
    final encryptString = str.replaceAll('\\', '');
    final dataString = encryptString.substring(
      encryptString.indexOf('p;}(') + 'p;}('.length,
    );
    final imageListStartIndex = dataString.indexOf('":[') + 2;
    final imageListEndIndex = dataString.indexOf('"],') + 2;
//    final encryptImageString = dataString.substring(
//      imageListStartIndex,
//      imageListEndIndex,
//    );
    
    var jsonString = dataString.substring(
      dataString.indexOf('({"') + 1,
      dataString.indexOf('}})') + 2,
    );

//    final encryptPath = dataString.substring(
//      dataString.indexOf(':"/', imageListEndIndex) + 2,
//      dataString.indexOf('/",', imageListEndIndex) + 1,
//    );
//
    final aStartIndex = dataString.indexOf(');\',') + 4;
    final a = int.parse(dataString.substring(
      aStartIndex,
      dataString.indexOf(',', aStartIndex),
    ));
    final wordStringList = LZString.decompressFromBase64(
        dataString.substring(
            dataString.indexOf(',\'', aStartIndex) + 2,
            dataString.indexOf('\'[\'', aStartIndex))
    ).split('|');
    int c = wordStringList.length;
    Map<String, String> keyValueMap = Map();
    while(c-- > 0) {
      var key = getKey(a, c);
      keyValueMap[key] = wordStringList[c] != '' ? wordStringList[c] : key ;
    }
//    final encryptImageList = json.decode(encryptImageString);
    final regExp = RegExp('\\b\\w+\\b');
//    final path = encryptPath.replaceAllMapped(
//        regExp, (match) {
//      return keyValueMap[match.group(0)];
//    });
//    final imagePathList = encryptImageList.map((str) => path + str.replaceAllMapped(regExp, (match) {
//      return  keyValueMap[match.group(0)];
//    })).toList(growable: false);
    jsonString = jsonString.replaceAllMapped(
        regExp, (match) {
      return keyValueMap[match.group(0)];
    }).replaceAll(':,', ':null,');
    final jsonValue = json.decode(jsonString);
    final cid = jsonValue['chapterId'];
    final md5 = jsonValue['sl']['md5'];
    List<String> imageList = jsonValue['images'].cast<String>();
    
    return imageList.map((url) => '${jsonValue['path'] ?? ''}$url?cid=$cid&md5=$md5').toList();
  }

  static String getKey(int a,int c) {
    return (c < a ? "" : getKey(a, (c / a).floor())) + ((c = c % a) > 35 ? String.fromCharCode(c + 29) : c.toRadixString(36));
  }
}