import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/calendar.dart';
import '../services/geminiai_service.dart';
import '../model/message_model.dart';
import '../services/encryption_services.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleGeminiService _geminiService = GoogleGeminiService();
  final EncryptionServices _encryptionServices = EncryptionServices();

  Future<bool> hasChatHistory(String userID) async {
    final querySnapshot =
        await _firestore
            .collection('chat_rooms')
            .where('createdBy', isEqualTo: userID)
            .limit(1)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<String> getTopic(String chatRoomID) async {
    DocumentReference documentReference = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID);
    String topic;

    try {
      final docSnapshot = await documentReference.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          topic = data['topic'];
          return topic;
        }
      } else {
        log('Document does not exist');
      }
    } catch (e) {
      log('Error getting document: $e');
    }

    return '';
  }

  void onDeleteChat(String chatRoomId) async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages');

      final messagesSnapshot = await messagesRef.get();

      // Delete all messages in the subcollection
      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Now delete the chat room document itself
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .delete();

      log('Chat room and messages deleted successfully.');
    } catch (e) {
      log('Error deleting chat room: $e');
    }
  }


  Stream<List<QueryDocumentSnapshot>> getChatRoomsStream() {
    String currentUserID = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('createdBy', isEqualTo: currentUserID)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Map<String, List<QueryDocumentSnapshot>> groupChatRoomsByDate(
    List<QueryDocumentSnapshot> docs,
  ) {
    Map<String, List<QueryDocumentSnapshot>> grouped = {};

    for (var doc in docs) {
      final dateField = doc['date'];
      final timestamp =
          (dateField is Timestamp) ? dateField.toDate() : DateTime.now();
      final date = DateFormat('dd-MM-yyyy').format(timestamp);

      grouped.putIfAbsent(date, () => []).add(doc);
    }

    return grouped;
  }

  Widget getTopicList({
    required List<QueryDocumentSnapshot> docs,
    required void Function(String chatRoomId) onTapTopic,
    required void Function(String datekey) initScrollControllerFor,
    required void Function() createNewChatroom,
    required Map<String, ScrollController> controllers,
    required Map<String, bool> showUpArrow,
    required Map<String, bool> showDownArrow,
    required BuildContext context,
    required String currentChatRoom,
    required Function(String) onDateSelected,
    required String selectedDate,
  }) {
    final grouped = groupChatRoomsByDate(docs);
    final DateTime now = DateTime.now();
    final String today = DateFormat('dd-MM-yyyy').format(now);
    final String yesterday = DateFormat(
      'dd-MM-yyyy',
    ).format(now.subtract(Duration(days: 1)));
    final entries = grouped.entries.toList();

    return Column(
      children: [
        Column(
          children:
              entries.take(2).map((entry) {
                final date = entry.key;
                final chatRooms = entry.value;
                final isToday = date == today;
                final isYesterday = date == yesterday;
                initScrollControllerFor(date);
                final controller = controllers[date]!;
                final showUp = showUpArrow[date] ?? false;
                final showDown = showDownArrow[date] ?? false;

                final chatItems =
                    chatRooms.map<Widget>((doc) {
                      final topic = doc.get('topic')?.toString() ?? '';
                      final chatRoomId = doc.id;

                      return InkWell(
                        onTap: () => onTapTopic(chatRoomId),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '\u2022',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    topic.isNotEmpty ? topic : 'Topicless Chat',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap:
                                    () => showDialog<String>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        24,
                                                        24,
                                                        24,
                                                        8,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Apa kamu yakin ingin menghapus riwayat curhat ini?",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                        "Setelah menghapus riwayat curhat, kamu tidak dapat melihatnya kembali.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  thickness: 1,
                                                  height: 1,
                                                  color: Color(0xFF366870),
                                                ),
                                                IntrinsicHeight(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          customBorder: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        16.0,
                                                                      ),
                                                                ),
                                                          ),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            onDeleteChat(
                                                              chatRoomId,
                                                            );
                                                            if (currentChatRoom ==
                                                                chatRoomId) {
                                                              createNewChatroom();
                                                            }
                                                            showUpArrow[date] =
                                                                false;
                                                            showDownArrow[date] =
                                                                false;
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),
                                                            alignment:
                                                                Alignment
                                                                    .center,
                                                            child: Text(
                                                              'Yakin',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        color: Color(
                                                          0xFF366870,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          customBorder: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        16.0,
                                                                      ),
                                                                ),
                                                          ),
                                                          onTap: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 16,
                                                                ),
                                                            alignment:
                                                                Alignment
                                                                    .center,
                                                            child: Text(
                                                              'Tidak',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList();

                return Container(
                  color: const Color(0xFF284082),
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Text(
                          isToday
                              ? 'Hari Ini'
                              : (isYesterday ? 'Kemarin' : date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      SizedBox(
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 4,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Scrollable area
                              SizedBox(
                                height: 80,
                                child: ClipRect(
                                  child: SingleChildScrollView(
                                    controller: controller,
                                    physics: const BouncingScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: chatItems,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Scroll to top arrow (visually moved up)
                              if (showUp)
                                Positioned(
                                  top: 0,
                                  child: Transform.translate(
                                    offset: Offset(0, -20),
                                    // move it up visually by 20px
                                    child: IconButton(
                                      onPressed: () {
                                        controller.animateTo(
                                          0.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.keyboard_arrow_up,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),

                              // Scroll to bottom arrow (visually moved down)
                              if (showDown)
                                Positioned(
                                  bottom: 0,
                                  child: Transform.translate(
                                    offset: Offset(0, 20),
                                    // move it down visually by 20px
                                    child: IconButton(
                                      onPressed: () {
                                        controller.animateTo(
                                          controller.position.maxScrollExtent,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8),
                      const Divider(color: Colors.white),
                    ],
                  ),
                );
              }).toList(),
        ),
        ListTile(
          tileColor: Color(0xFF284082),
          dense: true,
          contentPadding: const EdgeInsets.only(top: 0, left: 16, bottom: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Atur Tanggal Riwayat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  selectedDate.isNotEmpty ? selectedDate : 'DD/MM/YY',
                  style: GoogleFonts.josefinSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (_) => CustomCalendarWidget(
                      onDateSelected: (formattedDate) async {
                        onDateSelected(formattedDate);
                      },
                    ),
              ),
        ),
        const Divider(height: 1),
        Column(
          children: [
            ...grouped.entries.where((entry) => entry.key == selectedDate).map((
              entry,
            ) {
              final date = entry.key;
              final chatRooms = entry.value;
              final isToday = date == today;
              final isYesterday = date == yesterday;
              initScrollControllerFor(date);
              final controller = controllers[date]!;
              final showUp = showUpArrow[date] ?? false;
              final showDown = showDownArrow[date] ?? false;

              final chatItems =
                  chatRooms.map<Widget>((doc) {
                    final topic = doc.get('topic')?.toString() ?? '';
                    final chatRoomId = doc.id;

                    return InkWell(
                      onTap: () => onTapTopic(chatRoomId),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '\u2022',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  topic.isNotEmpty ? topic : 'Topicless Chat',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap:
                                  () => showDialog<String>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      24,
                                                      24,
                                                      24,
                                                      8,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Apa kamu yakin ingin menghapus riwayat curhat ini?",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      "Setelah menghapus riwayat curhat, kamu tidak dapat melihatnya kembali.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                thickness: 1,
                                                height: 1,
                                                color: Color(0xFF366870),
                                              ),
                                              IntrinsicHeight(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        customBorder:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                          16.0,
                                                                        ),
                                                                  ),
                                                            ),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          onDeleteChat(
                                                            chatRoomId,
                                                          );
                                                          if (currentChatRoom ==
                                                              chatRoomId) {
                                                            createNewChatroom();
                                                          }
                                                          showUpArrow[date] =
                                                              false;
                                                          showDownArrow[date] =
                                                              false;
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'Yakin',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      color: Color(0xFF366870),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        customBorder:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                          16.0,
                                                                        ),
                                                                  ),
                                                            ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'Tidak',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList();

              return Container(
                color: const Color(0xFF284082),
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        isToday ? 'Hari Ini' : (isYesterday ? 'Kemarin' : date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    SizedBox(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 4,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Scrollable area
                            SizedBox(
                              height: 80,
                              child: ClipRect(
                                child: SingleChildScrollView(
                                  controller: controller,
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: chatItems,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Scroll to top arrow (visually moved up)
                            if (showUp)
                              Positioned(
                                top: 0,
                                child: Transform.translate(
                                  offset: Offset(0, -20),
                                  // move it up visually by 20px
                                  child: IconButton(
                                    onPressed: () {
                                      controller.animateTo(
                                        0.0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_up,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),

                            // Scroll to bottom arrow (visually moved down)
                            if (showDown)
                              Positioned(
                                bottom: 0,
                                child: Transform.translate(
                                  offset: Offset(0, 20),
                                  // move it down visually by 20px
                                  child: IconButton(
                                    onPressed: () {
                                      controller.animateTo(
                                        controller.position.maxScrollExtent,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8),
                    const Divider(color: Colors.white),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Stream<QuerySnapshot> getChatRooms(DateTime date) {
    final startOfDay = date;
    final endOfDay = startOfDay.add(Duration(days: 1));
    final String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('chatrooms')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThan: endOfDay)
        .where('createdBy', isEqualTo: uid)
        .snapshots();
  }

  String _generateChatRoomID(String userID) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${userID}_$timestamp";
  }

  Future<String> getChatRoomID() async {
    String currentUserID = _auth.currentUser!.uid;
    final chatRoomID = _generateChatRoomID(currentUserID);
    await _firestore.collection("chat_rooms").doc(chatRoomID).set({
      "topic": '',
      "createdBy": currentUserID,
      "createdAt": FieldValue.serverTimestamp(),
      "date": Timestamp.now(),
    });
    return chatRoomID;
  }

  Future<Map<String, dynamic>> _getGeminiResponse(
    String message, {
    bool isFirstMessage = false,
    existingChatRoomID,
  }) async {
    String currentUserID = _auth.currentUser!.uid;
    if (message.isEmpty) {
      return {
        'response': 'Empty message, please enter something.',
        'chatID': existingChatRoomID,
      };
    }

    final reply = await _geminiService.sendMessage(
      message: message,
      currentUserID: currentUserID,
      isFirstMessage: isFirstMessage,
      existingChatRoomID: existingChatRoomID,
    );

    if (reply != null) {
      final responseText = reply['response'];
      final warning = reply['warning'];
      final chatID = reply['chatID'];
      final topic = reply['topic'];

      return {
        'response': responseText ?? 'Failed to get a response.',
        'warning': warning ?? 'safe',
        'chatID': chatID ?? existingChatRoomID,
        'topic': topic ?? '',
      };
    }
    return {
      'response': 'Failed to get a response',
      'chatID': existingChatRoomID,
    };
  }

  Future<void> saveUserMessage(String message, String existingChatRoomID) async {
    final String currentUserID = _auth.currentUser!.uid;

    final encryptedMessage = await _encryptionServices.encryptMessageForUser(
      currentUserID,
      message,
      _firestore,
    );

    await saveToFirestore(encryptedMessage!, existingChatRoomID, currentUserID);
  }


  Future<Map<String, dynamic>> sendMessage(
    String message, {
    bool isFirstMessage = false,
    existingChatRoomID,
  }) async {
    final result = await _getGeminiResponse(
      message,
      isFirstMessage: isFirstMessage,
      existingChatRoomID: existingChatRoomID,
    );
    final response = result['response'];
    final warning = result['warning'];

    final topic = result['topic'];
    await _firestore.collection("chat_rooms").doc(existingChatRoomID).update({
      "topic": topic,
      "date": Timestamp.now(),
    });

    final encryptedMessage = await _encryptionServices.encryptMessageForUser(
      _auth.currentUser!.uid,
      response,
      _firestore,
    );

    saveToFirestore(encryptedMessage!, existingChatRoomID, 'gemini');

    return {'warning': warning ?? 'safe'};
  }

  Stream<QuerySnapshot> getMessages(String chatID) {
    if (chatID.isEmpty) {
      return Stream.empty();
    }

    return _firestore
        .collection("chat_rooms")
        .doc(chatID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> saveToFirestore(String message, chatRoomID, senderID) async {
    Message newMessage = Message(
      senderID: senderID,
      message: message,
      timestamp: Timestamp.now(),
    );

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }
}
