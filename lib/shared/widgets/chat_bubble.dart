import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Timestamp timestamp;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = timestamp.toDate();
    final String formattedTime = DateFormat('hh:mm a').format(dateTime);

    Future<Image?> getBase64Image() async {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (doc.exists && doc['photoProfile'] != null) {
        String base64Str = doc['photoProfile'];
        Uint8List bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.cover);
      }

      return null;
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child:
          isCurrentUser
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //container
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                        bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 7,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        // ensures height wraps content
                        children: [
                          Text(
                            message,
                            style: const TextStyle(fontSize: 16),
                            softWrap: true,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //foto user
                  FutureBuilder<Image?>(
                    future: getBase64Image(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: snapshot.data!.image,
                            ),
                        );
                      }

                      return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.transparent,
                            child: SvgPicture.asset('assets/icons/round-profile.svg'),
                          ),
                      );
                    },
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //foto
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircleAvatar(radius: 16, backgroundColor: Colors.transparent, child: SvgPicture.asset('assets/icons/round-profile.svg',),),
                  ),

                  //container
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                        bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 7,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min, // ensures height wraps content
                        children: [
                          Text(
                            message,
                            style: const TextStyle(fontSize: 16),
                            softWrap: true,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
