import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/asymmetric/api.dart' as encrypt;

class EncryptionServices extends StatelessWidget {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  const EncryptionServices({super.key});

  Future<String?> getPublicKeyFromFirestore(String userId, FirebaseFirestore firestore) async {
    final snapshot = await firestore.collection("Users").doc(userId).get();
    return snapshot.data()?['public-key'];
  }

  Future<String?> encryptMessageForUser(String userId, String message, FirebaseFirestore firestore) async {
    final publicPem = await getPublicKeyFromFirestore(userId, firestore);
    if (publicPem == null) return null;

    final encrypter = getEncrypterFromPublicPem(publicPem);
    final encrypted = encrypter.encrypt(message);
    return encrypted.base64;
  }

  Future<encrypt.Encrypter> loadPublicEncrypter() async {
    final publicPem = await rootBundle.loadString('assets/keys/public.pem');
    final parser = encrypt.RSAKeyParser();
    final publicKey = parser.parse(publicPem) as encrypt.RSAPublicKey;
    return encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
  }


  encrypt.Encrypter getEncrypterFromPublicPem(String publicPem) {
    final parser = encrypt.RSAKeyParser();
    final publicKey = parser.parse(publicPem) as encrypt.RSAPublicKey;

    return encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
  }

  Future<String> encryptMessage(String message) async {
    final encrypter = await loadPublicEncrypter();
    final encrypted = encrypter.encrypt(message);
    return encrypted.base64;
  }

  encrypt.Encrypter getEncrypterFromPrivatePem(String privatePem) {
    final parser = encrypt.RSAKeyParser();
    final privateKey = parser.parse(privatePem) as encrypt.RSAPrivateKey;

    return encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
  }

  Future<String> decryptMessage(String encryptedBase64) async {
    final privatePem = await secureStorage.read(key: 'private-key');
    if (privatePem == null) throw Exception("Private key not found");

    final encrypter = getEncrypterFromPrivatePem(privatePem);
    final decrypted = encrypter.decrypt64(encryptedBase64);
    return decrypted;
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
