import 'dart:math';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:argon2/argon2.dart' as argon;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:asn1lib/asn1lib.dart';

class ServerHybridEncryptedPayload {
  final Uint8List rsaEncryptedAesKey;
  final Uint8List iv;
  final Uint8List aesEncryptedCiphertext;
  final Uint8List authenticationTag;

  ServerHybridEncryptedPayload({
    required this.rsaEncryptedAesKey,
    required this.iv,
    required this.aesEncryptedCiphertext,
    required this.authenticationTag,
  });

  // Factory that takes a JSON string (can still be useful if you have a string elsewhere)
  factory ServerHybridEncryptedPayload.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return ServerHybridEncryptedPayload.fromMap(jsonMap); // Delegate to fromMap
    } catch (e) {
      print('Error in ServerHybridEncryptedPayload.fromJsonString: $e');
      throw FormatException('Invalid JSON string for hybrid payload: ${e.toString()}');
    }
  }

  // New/Updated factory that directly takes a Map
  factory ServerHybridEncryptedPayload.fromMap(Map<String, dynamic> map) {
    try {
      final String? encryptedKeyB64 = map['encryptedKey'] as String?;
      final String? ivB64 = map['iv'] as String?;
      final String? ciphertextB64 = map['ciphertext'] as String?;
      final String? tagB64 = map['tag'] as String?;

      if (encryptedKeyB64 == null || ivB64 == null || ciphertextB64 == null || tagB64 == null) {
        throw FormatException(
            'One or more required fields (encryptedKey, iv, ciphertext, tag) are missing from payload map. Found: ${map.keys.join(', ')}');
      }

      return ServerHybridEncryptedPayload(
        rsaEncryptedAesKey: base64Decode(encryptedKeyB64),
        iv: base64Decode(ivB64),
        aesEncryptedCiphertext: base64Decode(ciphertextB64),
        authenticationTag: base64Decode(tagB64),
      );
    } catch (e) {
      print('Error creating ServerHybridEncryptedPayload from map: $e');
      throw FormatException('Invalid map structure or Base64 for hybrid payload: ${e.toString()}');
    }
  }
}

Future<Uint8List> _rsaDecryptAesKeyBytes(
    Uint8List rsaEncryptedAesKeyBytes,
    RSAPrivateKey userRsaPrivateKey, {
      Uint8List? oaepLabelBytes,
    }) async {
  try {
    final rsaEngine = RSAEngine();
    final decryptor = OAEPEncoding.withSHA256(rsaEngine, oaepLabelBytes)
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(userRsaPrivateKey));

    if (rsaEncryptedAesKeyBytes.length != decryptor.inputBlockSize) {
      throw ArgumentError(
          'Invalid RSA encrypted AES key length. Expected ${decryptor.inputBlockSize} bytes, '
              'got ${rsaEncryptedAesKeyBytes.length} bytes.');
    }
    return decryptor.process(rsaEncryptedAesKeyBytes);
  } catch (e) {
    print("RSA decryption of AES key failed: $e");
    throw Exception("Failed to decrypt symmetric key: ${e.toString()}");
  }
}

Future<String> decryptHybridResponseFromServer(Map<String, dynamic> serverJsonPayloadMap) async {
  try {
    // 1. The input is already a Map. Use the .fromMap factory.
    final ServerHybridEncryptedPayload payload =
    ServerHybridEncryptedPayload.fromMap(serverJsonPayloadMap);

    // 2. Get the user's RSA private key securely
    final RSAPrivateKey userPrivateKey = await _getPrivateKeyFromSecureStorage();

    // 3. Decrypt the AES key using RSA-OAEP
    final Uint8List decryptedAesKeyBytes = await _rsaDecryptAesKeyBytes(
      payload.rsaEncryptedAesKey,
      userPrivateKey,
      oaepLabelBytes: null,
    );

    // 4. Decrypt the actual message using AES-GCM
    final GCMBlockCipher aesGcmCipher = GCMBlockCipher(AESEngine());

    final AEADParameters aeadParameters = AEADParameters(
      KeyParameter(decryptedAesKeyBytes),
      128,
      payload.iv,
      Uint8List(0),
    );

    aesGcmCipher.init(false, aeadParameters);

    final Uint8List ciphertextAndTag =
    Uint8List.fromList(payload.aesEncryptedCiphertext + payload.authenticationTag);

    final Uint8List decryptedMessageBytes = aesGcmCipher.process(ciphertextAndTag);

    // 5. Decode the decrypted bytes (UTF-8) to a String
    return utf8.decode(decryptedMessageBytes);

  } on InvalidCipherTextException catch (e) {
    print("AES-GCM decryption failed: MAC check failed (invalid tag or tampered ciphertext). Error: $e");
    throw Exception("Decryption failed: Data integrity check failed. The message may have been altered.");
  } catch (e) {
    print("Hybrid decryption from server failed: $e");
    throw Exception("Failed to decrypt response from server: ${e.toString()}");
  }
}

Uint8List _generateSalt([int length = 16]) {
  final rand = Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => rand.nextInt(256)));
}

Uint8List _generateIV([int length = 12]) {
  final rand = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => rand.nextInt(256)));
}

Uint8List _deriveKeyWithArgon2id({
  required String password,
  required Uint8List salt,
  int hashLength = 32,
  int iterations = 3,
  int memoryInKB = 65536,
  int parallelism = 1,
}) {
  final generator = argon.Argon2BytesGenerator();

  final params = argon.Argon2Parameters(
    Argon2Parameters.ARGON2_id,
    salt,
    version: Argon2Parameters.ARGON2_VERSION_13,
    iterations: iterations,
    memoryPowerOf2: (log(memoryInKB) / log(2)).round(),
    lanes: parallelism,
  );

  generator.init(params);

  final output = Uint8List(hashLength);

  generator.generateBytes(
    utf8.encode(password),
    output,
  );

  return output;
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPair({int bitLength = 4096}) {
  final secureRandom = _getSecureRandom();

  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom,
    ));

  final keyPairs = keyGen.generateKeyPair();
  final publicKey = keyPairs.publicKey as RSAPublicKey;
  final privateKey = keyPairs.privateKey as RSAPrivateKey;
  final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> rsaKeyPairs = AsymmetricKeyPair(publicKey, privateKey);

  return rsaKeyPairs;
}

SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final seed = Uint8List(32);
  final random = Random.secure();
  for (int i = 0; i < seed.length; i++) {
    seed[i] = random.nextInt(256);
  }
  secureRandom.seed(KeyParameter(seed));
  return secureRandom;
}


Uint8List serializePrivateKey(RSAPrivateKey privateKey) {
  final keyMap = {
    'modulus': privateKey.n.toString(),
    'privateExponent': privateKey.d.toString(),
    'p': privateKey.p.toString(),
    'q': privateKey.q.toString(),
  };

  final jsonStr = jsonEncode(keyMap);
  return utf8.encode(jsonStr);
}

String serializePublicKeyToJsonBase64(RSAPublicKey publicKey) {
  final keyMap = {
    'modulus': publicKey.modulus.toString(),
    'exponent': publicKey.exponent.toString(),
  };
  final jsonStr = jsonEncode(keyMap);
  final base64Encoded = base64Encode(utf8.encode(jsonStr));
  return base64Encoded;
}

RSAPublicKey? deserializePublicKeyFromJsonBase64(String base64Content) {
  try {
    final jsonStr = utf8.decode(base64Decode(base64Content));
    final keyMap = jsonDecode(jsonStr) as Map<String, dynamic>;

    final modulus = BigInt.tryParse(keyMap['modulus'] as String);
    final exponent = BigInt.tryParse(keyMap['exponent'] as String);

    if (modulus != null && exponent != null) {
      return RSAPublicKey(modulus, exponent);
    } else {
      print("Failed to parse modulus or exponent from JSON");
      return null;
    }
  } catch (e) {
    print("Error deserializing custom JSON Base64: $e");
    return null;
  }
}

RSAPrivateKey deserializePrivateKey(Uint8List data) {
  final jsonStr = utf8.decode(data);
  final keyMap = jsonDecode(jsonStr);

  final modulus = BigInt.parse(keyMap['modulus']);
  final privateExponent = BigInt.parse(keyMap['privateExponent']);
  final p = BigInt.parse(keyMap['p']);
  final q = BigInt.parse(keyMap['q']);

  return RSAPrivateKey(modulus, privateExponent, p, q);
}

Uint8List aesGcmEncrypt(Uint8List key, Uint8List plaintext, Uint8List iv, Uint8List aad) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      true,
      AEADParameters(KeyParameter(key), 128, iv, aad),
    );

  return cipher.process(plaintext);
}

Uint8List aesGcmDecrypt(Uint8List key, Uint8List ciphertext, Uint8List iv, Uint8List aad) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false, // false = decryption mode
      AEADParameters(KeyParameter(key), 128, iv, aad),
    );

  return cipher.process(ciphertext);
}

Future<List<dynamic>> generateUserKeyPairs(String currentUserID, String password) async {
  // Generations: Key Pairs, Salt, Derived Symmetric Key, and Initialization Vector (IV)
  final keyPairRSA = _generateRSAKeyPair();
  Uint8List salt = _generateSalt();
  Uint8List iv = _generateIV();
  Uint8List derivedSymmetricKey = _deriveKeyWithArgon2id(password: password, salt: salt);

  // Encrypting Private Key before returning value
  final publicKey = keyPairRSA.publicKey;
  final privateKey = keyPairRSA.privateKey;
  final serializedPublicKey = serializePublicKeyToJsonBase64(publicKey);
  final serializedPrivateKey = serializePrivateKey(privateKey);
  final aad = Uint8List(0);
  final encryptedPrivateKey = aesGcmEncrypt(derivedSymmetricKey, serializedPrivateKey, iv, aad);

  return [serializedPublicKey, encryptedPrivateKey, iv, salt];
}

Future<void> getPrivateKeyFromFirestore(String currentUserID, String password) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(currentUserID);

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    final Uint8List encryptedPrivateKey = base64Decode(data?['encryptedPrivateKey']);
    final Uint8List iv = base64Decode(data?['iv']);
    final Uint8List salt = base64Decode(data?['salt']);
    final Uint8List aad = Uint8List(0);
    final derivedSymmetricKey = _deriveKeyWithArgon2id(password: password, salt: salt);
    final decryptedPrivateKey = aesGcmDecrypt(derivedSymmetricKey, encryptedPrivateKey, iv, aad);
    final secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
    await secureStorage.write(key: 'privateKey', value: base64Encode(decryptedPrivateKey));
  } else {
    print('Document does not exist');
  }
  return;
}

// --- NEW Encryption (Single Block, SHA-256 using correct factory) ---
String rsaEncryptSingleBlock(String plaintext, RSAPublicKey publicKey, [Uint8List? encodingParams]) {
  final data = Uint8List.fromList(utf8.encode(plaintext));

  // Use SHA-256 for OAEP via the correct factory
  final encryptor = OAEPEncoding.withSHA256(RSAEngine(), encodingParams)
    ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

  // Check if plaintext is too long (Pointycastle's process() will also throw an error)
  // Max size = key_bytes - 2*hash_bytes - 2. e.g., 4096-bit key (512b), SHA-256 (32b) => 512 - 64 - 2 = 446 bytes
  if (data.length > encryptor.inputBlockSize) {
    throw ArgumentError(
        'Plaintext too long for single RSA-OAEP block (max ${encryptor.inputBlockSize} bytes for current key/SHA-256). Use hybrid encryption for longer data.');
  }

  final encryptedMessageBytes = encryptor.process(data);
  return base64Encode(encryptedMessageBytes);
}

// --- NEW Decryption (Single Block, SHA-256 using correct factory) ---
Future<String> rsaDecryptSingleBlock(String encryptedBase64, [Uint8List? encodingParams]) async {
  final Uint8List encryptedBytes = base64Decode(encryptedBase64);
  final RSAPrivateKey privateKey = await _getPrivateKeyFromSecureStorage();

  // Use SHA-256 for OAEP via the correct factory
  final decryptor = OAEPEncoding.withSHA256(RSAEngine(), encodingParams)
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  // For decryption, inputBlockSize is the RSA key size.
  // Ciphertext should be exactly this size.
  if (encryptedBytes.length != decryptor.inputBlockSize) {
    throw ArgumentError(
        'Invalid ciphertext length. Expected ${decryptor.inputBlockSize} bytes for RSA key, got ${encryptedBytes.length} bytes.');
  }

  final decryptedBytes = decryptor.process(encryptedBytes);
  return utf8.decode(decryptedBytes);
}

Future<RSAPrivateKey> _getPrivateKeyFromSecureStorage() async {
  final secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final privateKey = await secureStorage.read(key: 'privateKey');
  final decodedKey = base64Decode(privateKey!);
  return deserializePrivateKey(decodedKey);
}

Future<RSAPublicKey> parsePublicKeyFromPem(String pem) async {
  final publicKey = CryptoUtils.rsaPublicKeyFromPem(pem);
  return publicKey;
}



