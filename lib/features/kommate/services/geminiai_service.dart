import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'encryption_services.dart';
import 'package:http/http.dart' as http;

class GoogleGeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionServices _encryptionServices = EncryptionServices();

  Future<Map<String, String>?> sendMessage({
    required String message,
    required String currentUserID,
    required bool isFirstMessage,
    String? existingChatRoomID,
  }) async {
    final workerUrl = 'https://gemini-vercel-1gadwt7ds-gosyens-projects.vercel.app/api/gemini';

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

        final decrypted = await _encryptionServices.decryptMessage(encrypted);

        return {
          'senderID': msg['senderID'],
          'message': decrypted,
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
      'userMessage': message,
      'currentUserID': currentUserID,
      'existingChatRoomID': existingChatRoomID,
      'isFirstMessage': isFirstMessage,
      'chatHistory': serializedChatHistory,
    });

    log('Serialized chat history: ${jsonEncode(serializedChatHistory)}');

    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fullText = data['candidates'][0]['content']['parts'][0]['text'];

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
