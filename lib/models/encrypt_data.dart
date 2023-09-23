import 'package:encrypt/encrypt.dart';

//encrypt data using AES algorithms
class AesEncryption{
  //store an encrypted value
  static Encrypted? encrypted;
  //to store the decrypted value
  static var decrypted;

  //encrypt the received text
  static encryptAES(asPlainText){
    //encryption key
    //a5JomwBwwO7PsUsHA6mzfA==sfqlz@86 = 32 length key
    final keyEncrypt = Key.fromUtf8('a5JomwBwwO7PsUsHA6mzfA==sfqlz@86');
    //Initialization Vector
    final initVector = IV.fromLength(16);
    //Encrypt using the AES algorithm with the key specified
    final encryptionAlgorithm = Encrypter(AES(keyEncrypt));
    encrypted = encryptionAlgorithm.encrypt(asPlainText, iv: initVector);
    //print(encrypted!.base64);
  }

  //decrypt the received text
  static decryptAES(asPlainText){
    //encryption key
    final keyEncrypt = Key.fromUtf8('a5JomwBwwO7PsUsHA6mzfA==sfqlz@86');
    //Initialization Vector
    final initVector = IV.fromLength(16);
    //Decrypt using the AES algorithm with the key specified
    final encryptionAlgorithm = Encrypter(AES(keyEncrypt));
    decrypted = encryptionAlgorithm.decrypt64(asPlainText, iv: initVector);
  }
}