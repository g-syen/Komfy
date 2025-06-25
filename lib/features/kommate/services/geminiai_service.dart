import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/encryption_services.dart';
import 'package:http/http.dart' as http;

class GoogleGeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>?> sendMessage({
    required String message,
    required String currentUserID,
    required bool isFirstMessage,
    String? existingChatRoomID,
  }) async {
    final workerUrl = 'https://gemini-vercel-6tfp92hps-gosyens-projects.vercel.app/api/gemini';
    final pem = """
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA4+lqkwrZa9+gZhojBYJs
ZWqJne3P3Jm+U2Ysqlm0zib8nGO7FdvwEkBb6p2e6eGPJhZr9L5dCgsAqLKiiNvg
YTSAcpA901a0M+RZ1chL03319JWHD3Sfb6vV3StDv+nvRcd4JWhaDsKZwf80WXw1
jzja5ZNJU5szsFOjkrIFfMztpu6peQEB+85AxTq4akrI4Ik0NWOO1qEe3y4rv3B6
pzg14EBk/Ur4zmYXVzpuXZ7WU/953YujQBIqxmaU/FTsBEL2CQWC4mHAW51g48mh
EjmE4r9S+2FachKLYsh3YAgE8XwaNyFBwnMp60jILOCAtYpdUetTpsgAE8OY4AWO
D8HGmIQrEMvTLtbnjGqTDmf+kPmEmvhLm0UMz1omWtHTsFM+b8isTQ0oG/a8VWBA
e141dO4VjI0Q6TTNOoi8fYktHAcn3iOWRBuGKLYKgI/ALO8lxG9VG4XxfJ1zX2PE
5dpwr7flC1DG+s2wtJlvx85sO2jgncWU1E2Cw6NjJAQUUia/Bn5OxcZ6WB0uasPd
b1LU7q1KuHYgIhgEHSfKZqPaybOH1jPmGLIMuDM0Tw6GmnIeffIXNX+IOEcxk67M
5gyNrCM/F0rtGhsZsLwytdgJJaiv+dEE2KROaBAcU+gN1nnm6dHf6BXyNXud+ptS
y2E8UvO4ApI0RGG60VDDGx8CAwEAAQ==
-----END PUBLIC KEY-----
""";
    final publicKey = await parsePublicKeyFromPem(pem);
    final encryptedMessage = rsaEncryptSingleBlock(message, publicKey);
    List<Map<String, dynamic>> chatHistory = [];
    if (!isFirstMessage && existingChatRoomID != null) {
      chatHistory = await _getLastMessages(existingChatRoomID, 15);
    }

    final List<Map<String, dynamic>> serializedChatHistory =
    await Future.wait(chatHistory.map((msg) async {
      try {
        final encrypted = msg['message'];
        if (encrypted == null || encrypted is! String) {
          throw Exception('Invalid message format: $encrypted');
        }

        final decrypted = await rsaDecryptSingleBlock(encrypted);
        final encryptedWithVercelKey = rsaEncryptSingleBlock(decrypted, publicKey);
        return {
          'senderID': msg['senderID'],
          'message': encryptedWithVercelKey,
          'timestamp': (msg['timestamp'] is Timestamp)
              ? (msg['timestamp'] as Timestamp).toDate().toIso8601String()
              : msg['timestamp']
        };
      } catch (e, stack) {
        log('Failed to decrypt message in chat history: ${msg['message']}', error: e, stackTrace: stack);
        throw Exception("Chat history decryption failed");
      }
    }));


    final String body = jsonEncode({
      'userMessage': encryptedMessage,
      'currentUserID': currentUserID,
      'existingChatRoomID': existingChatRoomID,
      'isFirstMessage': isFirstMessage,
      'chatHistory': serializedChatHistory,
    });

    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> fullGeminiResponseMap = jsonDecode(response.body);
      Map<String, dynamic> encryptedPayloadMap;
      try {
        encryptedPayloadMap = fullGeminiResponseMap['candidates'][0]['content']['parts'][0]['text'];
      } catch (e) {
        log("Error extracting encrypted payload from Gemini response: $e");
        throw Exception(e);
      }
      final fullText = await decryptHybridResponseFromServer(encryptedPayloadMap);

      final String topic = _extractTag(fullText, 'topic');
      final String geminiReply = _extractTag(fullText, 'response');
      final String warningLevel = _extractTag(fullText, 'warning');

      return {
        "response": geminiReply,
        "warning": warningLevel,
        "chatID": existingChatRoomID ?? "",
        "topic": topic,
      };
    } else {
      log('Vercel Worker error: ${response.body}');
      return null;
    }
  }


  Future<List<Map<String, dynamic>>> _getLastMessages(String existingChatRoomID, int limit) async {
    final snapshot = await _firestore
        .collection("chat_rooms")
        .doc(existingChatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList().reversed.toList();
  }

  String _extractTag(String text, String tag) {
    final start = text.indexOf('<$tag>');
    final end = text.indexOf('</$tag>');
    if (start == -1 || end == -1) return '';
    return text.substring(start + tag.length + 2, end).trim();
  }

}
