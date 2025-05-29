import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:komfy/shared/widgets/custom_textfield.dart';
import 'package:komfy/shared/icons/my_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/chat_bubble.dart';
import '../../../shared/widgets/number_list.dart';
import '../services/chat_service.dart';
import '../services/encryption_services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KommateScreen extends StatefulWidget {
  const KommateScreen({super.key});

  @override
  State<KommateScreen> createState() => _KommateScreenState();
}

class _KommateScreenState extends State<KommateScreen> {
  late final FocusNode _focusNode;
  final Map<String, Future<String>> _decryptionCache = {};
  Stream<QuerySnapshot>? _messageStream;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final EncryptionServices _encryptionServices = EncryptionServices();

  String _selectedDate = '';
  String _warning = '';
  String _existingChatRoomID = '';
  bool _isAwaitingResponse = false;
  bool _hasShownUrgentDialog = false;
  final Map<String, ScrollController> _controllers = {};
  final Map<String, bool> _showUpArrow = {};
  final Map<String, bool> _showDownArrow = {};

  void _initScrollControllerFor(String dateKey) {
    if (_controllers.containsKey(dateKey)) return;

    final controller = ScrollController();
    _controllers[dateKey] = controller;

    controller.addListener(() {
      final offset = controller.offset;
      final max = controller.position.maxScrollExtent;
      final currentUp = offset > 0;
      final currentDown = offset < max;

      // Only trigger rebuild if value changes
      if (_showUpArrow[dateKey] != currentUp ||
          _showDownArrow[dateKey] != currentDown) {
        setState(() {
          _showUpArrow[dateKey] = currentUp;
          _showDownArrow[dateKey] = currentDown;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
    if (_auth.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  _launchURL() async {
    final Uri url = Uri.parse('https://filkom.ub.ac.id/legacy/auth');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  _onTapTopic(String chatRoomID) {
    setState(() {
      _existingChatRoomID = chatRoomID;
      _messageStream = _chatService.getMessages(_existingChatRoomID);
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final Map<String, Duration?> suppressionDurations = {
    'None': null,
    '5 minutes': Duration(minutes: 5),
    '10 minutes': Duration(minutes: 10),
    '20 minutes': Duration(minutes: 20),
    '1 hour': Duration(hours: 1),
    '8 hours': Duration(hours: 8),
    '24 hours': Duration(hours: 24),
    'Forever': Duration(days: 365 * 100),
  };

  final List<String> tutorialKonseling = [
    "Klik tombol \"Jadwalkan Sekarang\"",
    "Anda akan dialihkan ke website FILKOM Apps.",
    "Login dengan akun Anda.",
    "Pilih Layanan \"Bimbingan Konseling\".",
    "Pilih \"Booking Layanan Konseling\".",
    "Pilih jadwal yang tersedia.",
    "Isi penjelasan singkat mengenai topik yang ingin dibicarakan (opsional).",
    "Pastikan jadwal yang Anda pilih sudah sesuai.",
    "Tekan tombol \"Daftar\".",
  ];

  Future<bool> shouldShowUrgentDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final nextAllowedTime = prefs.getInt('urgent_dialog_next_time') ?? 0;
    return DateTime.now().millisecondsSinceEpoch > nextAllowedTime;
  }

  Future<void> suppressUrgentDialog(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final nextTime = DateTime.now().add(duration).millisecondsSinceEpoch;
    await prefs.setInt('urgent_dialog_next_time', nextTime);
  }

  Future<void> openWhatsAppChat(String phoneNumber) async {
    final message =
        "Halo, pak Pras...\n\nPerkenalkan nama saya (...), dan saya mahasiswa FILKOM UB. Saya ingin berbicara dengan bapak terkait (...)";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal membuka WhatsApp. Pastikan sudah terpasang di perangkat Anda.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFD0E4FF),
      body: SafeArea(
        bottom: true,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(color: Color(0xFFD0E4FF)),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Text(
                  "Kommate",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),

              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 16, 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (context) {
                                    return IconButton(
                                      onPressed: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                      icon: Icon(MyIcons.menuBurger, size: 30),
                                    );
                                  },
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return StatefulBuilder(
                                          builder:
                                              (context, setState) => AlertDialog(
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
                                                            "We Care About You!",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            "Tidak harus buat janjian kok, cukup chat aja dulu bapaknya. "
                                                            "Semua akan terasa lebih ringan kalau kamu mulai terbuka... "
                                                            "tenang aja, gaada yang bakal nge-judge kamu  loh -- yuk, gapai ke profesional!",
                                                            textAlign:
                                                                TextAlign.justify,
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
                                                    ),
                                                    InkWell(
                                                      customBorder:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        16.0,
                                                                      ),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                        16.0,
                                                                      ),
                                                                ),
                                                          ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        openWhatsAppChat(
                                                          '6281803805321',
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      16.0,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      16.0,
                                                                    ),
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FaIcon(
                                                              FontAwesomeIcons
                                                                  .whatsapp,
                                                              color: Colors.green,
                                                              size: 28,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'WhatsApp ULTKSP',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors.green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(MyIcons.commentHeart, size: 30),
                                ),
                              ],
                            ),
                          ),

                          Expanded(child: _buildMessageList()),
                          _buildUserInput(),

                          if (_warning == 'urgent' && !_hasShownUrgentDialog)
                            Builder(
                              builder: (context) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) async {
                                  if (!await shouldShowUrgentDialog()) return;

                                  setState(() => _hasShownUrgentDialog = true);

                                  String selectedDuration = 'None';

                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return StatefulBuilder(
                                        builder:
                                            (context, setState) => AlertDialog(
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
                                                          "We Care About You!",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          "Kamu lagi capek ya? Kamu nggak sendirian kok. "
                                                          "Kadang perasaan itu memang berat untuk dipikul sendiri... "
                                                          "tapi kamu nggak harus menghadapinya sendirian -- yuk, gapai ke profesional!",
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Do not show again for:",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            DropdownButton<
                                                              String
                                                            >(
                                                              value:
                                                                  selectedDuration,
                                                              onChanged: (
                                                                String? value,
                                                              ) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(
                                                                    () =>
                                                                        selectedDuration =
                                                                            value,
                                                                  );
                                                                }
                                                              },
                                                              items:
                                                                  suppressionDurations.keys.map((
                                                                    String
                                                                    duration,
                                                                  ) {
                                                                    return DropdownMenuItem<
                                                                      String
                                                                    >(
                                                                      value:
                                                                          duration,
                                                                      child: Text(
                                                                        duration,
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: 1,
                                                    height: 1,
                                                  ),
                                                  InkWell(
                                                    customBorder:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                bottomLeft:
                                                                    Radius.circular(
                                                                      16.0,
                                                                    ),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                      16.0,
                                                                    ),
                                                              ),
                                                        ),
                                                    onTap: () async {
                                                      final selected =
                                                          suppressionDurations[selectedDuration];
                                                      if (selected != null) {
                                                        await suppressUrgentDialog(
                                                          selected,
                                                        );

                                                        if (selectedDuration ==
                                                            'Forever') {
                                                          final prefs =
                                                              await SharedPreferences.getInstance();
                                                          await prefs.setBool(
                                                            'urgent_dialog_suppressed_forever',
                                                            true,
                                                          );
                                                        }
                                                      } else {
                                                        // Optional: clear 'forever' if user selected 'None'
                                                        final prefs =
                                                            await SharedPreferences.getInstance();
                                                        await prefs.setBool(
                                                          'urgent_dialog_suppressed_forever',
                                                          false,
                                                        );
                                                      }

                                                      Navigator.pop(context);
                                                      openWhatsAppChat(
                                                        '6281803805321',
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    16.0,
                                                                  ),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                    16.0,
                                                                  ),
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          FaIcon(
                                                            FontAwesomeIcons
                                                                .whatsapp,
                                                            color: Colors.green,
                                                            size: 28,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'WhatsApp ULTKSP',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.green,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      );
                                    },
                                  );
                                });

                                return SizedBox(); // Placeholder
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Theme(
        data: ThemeData(
          dividerColor: Colors.white,
          dividerTheme: DividerThemeData(color: Colors.white),
        ),
        child: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          backgroundColor: Color(0xFF142553),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 150,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF142553)),
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: IconButton(
                                highlightColor: Colors.white.withAlpha(25),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  MyIcons.menuBurger,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Text(
                                'Komfy Menu',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/images/cat.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(MyIcons.commentHeart, color: Colors.white, size: 23),
                    SizedBox(width: 16),
                    Text(
                      'Hubungi ULTKSP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(
                        builder:
                            (context, setState) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: EdgeInsets.zero,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
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
                                          "We Care About You!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "Tidak harus buat janjian kok, cukup chat aja dulu bapaknya. "
                                          "Semua akan terasa lebih ringan kalau kamu mulai terbuka... "
                                          "tenang aja, gaada yang bakal nge-judge kamu  loh -- yuk, gapai ke profesional!",
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                  Divider(thickness: 1, height: 1),
                                  InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16.0),
                                        bottomRight: Radius.circular(16.0),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      openWhatsAppChat('6281803805321');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(16.0),
                                          bottomRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.whatsapp,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'WhatsApp ULTKSP',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Row(
                  children: [
                    Icon(MyIcons.calendar, color: Colors.white, size: 23),
                    const SizedBox(width: 10),
                    Text(
                      'Tutorial atur Jadwal Konseling',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(
                        builder:
                            (context, setState) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              insetPadding: EdgeInsets.all(0),
                              contentPadding: EdgeInsets.zero,
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            24,
                                            24,
                                            8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 25),
                                              Text(
                                                "Tutorial atur Jadwal Konseling",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              NumberList(tutorialKonseling),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: IconButton(
                                              padding: EdgeInsets.all(0.0),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        16,
                                      ),
                                      child: CustomButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          _launchURL();
                                        },
                                        text: "Jadwalkan Sekarang",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Row(
                  children: [
                    Icon(MyIcons.note, color: Colors.white, size: 23),
                    const SizedBox(width: 10),
                    Text(
                      'Mulai Chat Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  setState(() {
                    _existingChatRoomID = '';
                    Navigator.pop(context);
                  });
                },
              ),
              Divider(),
              ListTile(
                dense: true,
                minTileHeight: 0,
                contentPadding: EdgeInsets.only(top: 0, left: 16, bottom: 4),
                title: Text(
                  'Riwayat Curhat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: null,
              ),
              Divider(height: 1),

              _buildHistoryBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_existingChatRoomID.isEmpty || _messageStream == null) {
      return ListView(children: []);
    }

    return StreamBuilder(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error");
        if (!snapshot.hasData) return const Text("Loading...");

        final messages = snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });


        return ListView.builder(
          controller: _scrollController,
          itemCount:
              _isAwaitingResponse ? messages.length + 1 : messages.length,
          itemBuilder: (context, index) {
            if (_isAwaitingResponse && index == messages.length) {
              return _buildLoadingBubble();
            }
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildHistoryBody() {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _chatService.getChatRoomsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 50),
                Icon(MyIcons.emptyBoxFill, color: Colors.white, size: 40),
                SizedBox(height: 20),
                Text(
                  "Kamu belum memiliki riwayat curhat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return _chatService.getTopicList(
          docs: snapshot.data!,
          onTapTopic: _onTapTopic,
          initScrollControllerFor: _initScrollControllerFor,
          controllers: _controllers,
          showDownArrow: _showDownArrow,
          showUpArrow: _showUpArrow,
          context: context,
          currentChatRoom: _existingChatRoomID,
          createNewChatroom: () async {setState(() {
            _existingChatRoomID = '';
          });},
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          selectedDate: _selectedDate,
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;
    final messageId = doc.id; // or use hash of `data['message']`

    _decryptionCache[messageId] ??=
        _encryptionServices.decryptMessage(data["message"]);

    return FutureBuilder<String>(
      future: _decryptionCache[messageId],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Row(
            mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ChatBubble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
                timestamp: data['timestamp'],
              ),
            ],
          );
        }

        final decryptedMessage = snapshot.data ?? '[empty]';

        return Row(
          mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ChatBubble(
              message: decryptedMessage,
              isCurrentUser: isCurrentUser,
              timestamp: data['timestamp'],
            ),
          ],
        );
      },
    );
  }



  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          final isTextEmpty = value.text.trim().isEmpty;

          return Row(
            children: [
              // Expanded text field
              Expanded(
                child: CustomTextField(
                  hintText: 'Ketik pesan Anda!',
                  textFieldController: _controller,
                  chatField: true,
                ),
              ),

              const SizedBox(width: 8),

              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(MyIcons.sendFill),
                  color: isTextEmpty ? Colors.grey[300] : Colors.black,
                  onPressed:
                      isTextEmpty
                          ? null
                          : () async {
                            final Map<String, dynamic> result;
                            final String message = _controller.text.trim();
                            _controller.clear();

                            if (_existingChatRoomID.isEmpty) {
                              String chatRoomID =
                                  await _chatService.getChatRoomID();
                              await _chatService.saveUserMessage(
                                message,
                                chatRoomID,
                              );
                              setState(() {
                                _existingChatRoomID = chatRoomID;
                                _messageStream = _chatService.getMessages(
                                  chatRoomID,
                                );
                                _isAwaitingResponse = true;
                              });
                              result = await _chatService.sendMessage(
                                message,
                                isFirstMessage: true,
                                existingChatRoomID: chatRoomID,
                              );
                            } else {
                              await _chatService.saveUserMessage(
                                message,
                                _existingChatRoomID,
                              );
                              setState(() {
                                _messageStream = _chatService.getMessages(
                                  _existingChatRoomID,
                                );
                                _isAwaitingResponse = true;
                              });
                              result = await _chatService.sendMessage(
                                message,
                                existingChatRoomID: _existingChatRoomID,
                              );
                            }

                            setState(() {
                              _warning = result['warning'];
                              _messageStream = _chatService.getMessages(
                                _existingChatRoomID,
                              );

                              if (_warning == 'urgent') {
                                _hasShownUrgentDialog = false;
                              }

                              _isAwaitingResponse = false;
                            });
                          },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Gemini is on the left
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
