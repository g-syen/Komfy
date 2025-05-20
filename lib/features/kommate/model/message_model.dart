import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.message,
    required this.timestamp,
  });

  Map<String,dynamic> toMap() {
    return {
      'senderID': senderID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}