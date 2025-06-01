import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService extends StatelessWidget {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const EncryptionService({super.key});


  Future<bool> doesPrivateKeyExist() async {
    String? privateKey = await _secureStorage.read(key: 'private_key');
    return privateKey != null && privateKey.isNotEmpty;
  }

  Future<Map<String, RSAAsymmetricKey>> generateRSAKeyPair() async {
    final keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
    final secureRandom = FortunaRandom()
      ..seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(255)))));
    final generator = RSAKeyGenerator()
      ..init(ParametersWithRandom(keyParams, secureRandom));

    final pair = generator.generateKeyPair();
    return {
      'privateKey': pair.privateKey as RSAPrivateKey,
      'publicKey': pair.publicKey as RSAPublicKey,
    };
  }


  String encodePublicKeyToPem(RSAPublicKey publicKey) {
    final algorithmSeq =
        ASN1Sequence()
          ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.113549.1.1.1'))
          ..add(ASN1Null());

    final publicKeySeq =
        ASN1Sequence()
          ..add(ASN1Integer(publicKey.modulus!))
          ..add(ASN1Integer(publicKey.exponent!));

    final publicKeyBitString = ASN1BitString(publicKeySeq.encodedBytes);

    final topLevelSeq =
        ASN1Sequence()
          ..add(algorithmSeq)
          ..add(publicKeyBitString);

    final dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    return '-----BEGIN PUBLIC KEY-----\n$dataBase64\n-----END PUBLIC KEY-----';
  }

  String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final privateKeySeq =
        ASN1Sequence()
          ..add(ASN1Integer(BigInt.from(0)))
          ..add(ASN1Integer(privateKey.n!))
          ..add(ASN1Integer(BigInt.parse('65537')))
          ..add(ASN1Integer(privateKey.privateExponent!))
          ..add(ASN1Integer(privateKey.p!))
          ..add(ASN1Integer(privateKey.q!))
          ..add(
            ASN1Integer(
              privateKey.privateExponent! % (privateKey.p! - BigInt.one),
            ),
          )
          ..add(
            ASN1Integer(
              privateKey.privateExponent! % (privateKey.q! - BigInt.one),
            ),
          )
          ..add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

    final dataBase64 = base64.encode(privateKeySeq.encodedBytes);
    return '-----BEGIN RSA PRIVATE KEY-----\n$dataBase64\n-----END RSA PRIVATE KEY-----';
  }

  Future<void> savePublicKeyToFirestore(String publicKey) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .set({"public-key": publicKey}, SetOptions(merge: true));
  }


  Future<void> savePrivateKeyLocally(String privateKey) async {
    await _secureStorage.write(key: 'private-key', value: privateKey);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
