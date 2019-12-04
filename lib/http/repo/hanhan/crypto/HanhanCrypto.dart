class HanhanCrypto {
  static List<String> decryptImageList(String s) {
    var x = s.substring(s.length - 1);
    var xi = "abcdefghijklmnopqrstuvwxyz".indexOf(x) + 1;
    var sk = s.substring(s.length - xi - 12, s.length - xi - 1);
    s = s.substring(0, s.length - xi - 12);
    var k = sk.substring(0, sk.length - 1);
    var f = sk.substring(sk.length - 1);
    for(var i = 0; i < k.length; i++) {
      s = s.replaceAll(k.substring(i,i+1), '$i');
    }
    var ss = s.split(f);
    String imageListString = '';
    for(var i = 0; i < ss.length; i++) {
      imageListString += String.fromCharCode(int.parse(ss[i]));
    }
    return imageListString.split('|').toList(growable: false);
  }
}
