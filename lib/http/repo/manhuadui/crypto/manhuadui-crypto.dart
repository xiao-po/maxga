
import 'package:encrypt/encrypt.dart';

class ManhuaduiCrypto {
  static final key = Key.fromUtf8('123456781234567G');
  static final iv = IV.fromUtf8('ABCDEF1G34123412');


  static String decrypt(String content) {

    final encrypter = Encrypter(AES(
        ManhuaduiCrypto.key,
        mode: AESMode.cbc
    ));

    return encrypter.decrypt(
        Encrypted.fromBase64(content),
        iv: iv
    );



  }
}