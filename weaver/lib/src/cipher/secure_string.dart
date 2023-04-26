import 'package:encrypt/encrypt.dart';

late final Cipher cipher;

class SecureString {
  final String value;

  SecureString(this.value);

  String toJson() => cipher.encrypt(value);

  factory SecureString.fromJson(String json) =>
      SecureString(cipher.decrypt(json));
}

class Cipher {
  final IV _iv = IV.fromLength(16);
  final Encrypter _encrypter;
  final bool decryptionEnabled;

  Cipher(
    String key, {
    this.decryptionEnabled = false,
  }) : _encrypter = Encrypter(AES(Key.fromUtf8(key)));

  String encrypt(String string) => _encrypter.encrypt(string, iv: _iv).base64;

  String decrypt(String encrypted) =>
      decryptionEnabled ? _encrypter.decrypt64(encrypted, iv: _iv) : "********";
}
