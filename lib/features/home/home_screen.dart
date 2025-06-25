import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komfy/themes/typography.dart'; 
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:komfy/shared/widgets/mood_selector.dart';
import 'package:komfy/shared/widgets/feature_carousel.dart';
import 'package:komfy/shared/widgets/komynfo_card.dart';
import '../../../shared/widgets/number_list.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:komfy/themes/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMoodIndex = -1;
  bool hasFilledToday = false;
  bool isLoading = true;

  final List<Map<String, dynamic>> eduCardItems = [
  {
    'title': "Familiar?\nInilah istilah mental health yang sering digunakan!",
    'type': "Bacaan",
    'image': 'assets/images/kesehatan_mental.png',
    'isVideo': false,
  },
  {
    'title': "Merasa emosional?\nItu tandanya kamu adalah manusia",
    'type': "Bacaan",
    'image': 'assets/images/emosional.png',
    'isVideo': false,
  },
  {
    'title': "Tips regulasi stress untuk kestabilan mental",
    'type': "Tontonan",
    'image': 'assets/images/regulasi_stress.png',
    'isVideo': true,
  },
  {
    'title': "Lelah obatnya tidur aja? Kenali jenis lelah dan cara mengatasinya",
    'type': "Tontonan",
    'image': 'assets/images/jenis_lelah.png',
    'isVideo': true,
  },
];

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
  String username = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;
      final docSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if(docSnapshot.exists) {
        setState(() {
          username = docSnapshot['namaPanggilan'];
        });
      }
      if (user == null) {
        log("No user logged in.");
        setState(() {
          hasFilledToday = false;
          isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('mood_entries')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .limit(1)
          .get();

      setState(() {
        hasFilledToday = snapshot.docs.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      log("Error checking mood entry: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.018),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: screenWidth * 0.2), 
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.008),
                          child: Text(
                            "Gimana perasaan kamu saat ini?",
                            style: AppTypography.subtitle3.copyWith(
                            ),
                          ),
                        ),
                        isLoading
                            ? Center(
                          child: SizedBox(
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            child: CircularProgressIndicator(),
                                ),
                              )
                            : Column(
                                children: [
                                  hasFilledToday
                                      ? _buildCardRecap(context, screenWidth, screenHeight)
                                      : MoodSelector(
                                          screenWidth: screenWidth,
                                          selectedMoodIndex: selectedMoodIndex,
                                          onMoodSelected: (index) {
                                            setState(() {
                                              selectedMoodIndex = index;
                                            });

                                            if (index >= 0) {
                                              Navigator.pushNamed(
                                                context,
                                                '/mood_input',
                                                arguments: selectedMoodIndex,
                                              );
                                            }
                                          },
                                        ),
                                  SizedBox(height: screenHeight * 0.005),
                                  FeatureCarousel(),
                                  SizedBox(height: screenHeight * 0.012),
                                  Text(
                                    "Terasa lebih baik jika kita kenal dengan diri sendiri!",
                                    style: AppTypography.subtitle4.copyWith(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.04, // Responsive font size
                                    ),
                                  ),
                                  KomynfoCard(
                                    items: eduCardItems,
                                    onCardTap: (item) {
                                      if (item['isVideo'] == true) {
                                        Navigator.pushNamed(
                                          context,
                                          '/videoDetail',
                                          arguments: item,
                                        );
                                      } else {
                                        Navigator.pushNamed(
                                          context,
                                          '/articleDetail',
                                          arguments: item,
                                        );
                                      }
                                    },
                                  ),
                                  _buildMoreSection(screenWidth, screenHeight),
                                  SizedBox(height: screenHeight * 0.012),
                                  _buildBottomInfo(screenWidth, screenHeight),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: width * 0.25,
        left: width * 0.10,
        right: width * 0.1,
        bottom: width * 0.05,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(width * 0.125),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Komfy",
            style: AppTypography.title1.copyWith(
              color: AppColors.darkBlue3,
              height: 0.9,
            ),
          ),
          Text(
            "Hai, $username!",
            style: AppTypography.subtitle3.copyWith(
              color: AppColors.darkBlue3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection(double screenWidth, double screenHeight) {
    final baseStyle = AppTypography.bodyText3.copyWith(
      color: const Color(0xFF374957),
      fontSize: screenWidth * 0.035, // Responsive font size
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/komynfo_navbar');
      },
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.005), // Responsive padding
        child: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                TextSpan(
                  text: "Lihat lebih banyak di ",
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: "Komynfo",
                  style: baseStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: " →",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showULTKSPDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    var alertStyle = AlertStyle(
      animationType: AnimationType.grow,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      alertPadding: EdgeInsets.all(screenWidth * 0.04),
      backgroundColor: Colors.white,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      titleStyle: AppTypography.subtitle2.copyWith(
        color: Colors.black,
      ),
      descStyle: AppTypography.subtitle3.copyWith(
        color: Colors.black,
      ),
    );

    Alert(
      context: context,
      style: alertStyle,
      buttons: [],
      content: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04, 
              screenHeight * 0.04, 
              screenWidth * 0.04, 
              0
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Tutorial atur Jadwal Konseling",
                    style: AppTypography.subtitle2.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.012),
                NumberList(tutorialKonseling),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.04, 
                    0, 
                    screenWidth * 0.025, 
                    0
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _launchURL("https://filkom.ub.ac.id/apps/");
                      },
                      text: "Jadwalkan Sekarang",
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -screenHeight * 0.01,
            left: -screenWidth * 0.02,
            child: IconButton(
              icon: Icon(
                Icons.close, 
                color: Colors.black,
                size: screenWidth * 0.06, // Responsive icon size
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ).show();
  }

  Widget _buildBottomInfo(double screenWidth, double screenHeight) {
    final List<Map<String, dynamic>> infoItems = [
      {
        'icon': "assets/icons/journal.svg",
        'title': "Fitur Komfess",
        'description': "Menulis Jurnal juga bisa membuat kamu merasa lebih baik, loh!",
      },
      {
        'icon': "assets/icons/comment_heart.svg",
        'title': "ULTKSP FILKOM",
        'description': "Komfy bekerjasama dengan ULTKSP FILKOM! Hubungi?",
      },
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: infoItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.of(context).pushNamed('/navbar', arguments: {'initialIndex': 2});
                } else if (index == 1) {
                  _showULTKSPDialog(context);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0125),
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: screenWidth * 0.02,
                      offset: Offset(0, screenHeight * 0.005),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          item['icon'],
                          height: screenWidth * 0.07,
                          width: screenWidth * 0.075, // Responsive width
                        ),
                        SizedBox(width: screenWidth * 0.02), // Responsive spacing
                        Expanded(
                          child: Text(
                            item['description'],
                            style: AppTypography.bodyText4.copyWith(
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.006), // Responsive spacing
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item['title'],
                        style: AppTypography.bodyText4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardRecap(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: screenWidth * 0.0125,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Emoji-emoji miring di sekitar teks dengan posisi responsif
          Positioned(
            top: screenHeight * 0.012,
            left: screenWidth * 0.05,
            child: Transform.rotate(
              angle: 0.1,
              child: Text(
                '😟', 
                style: TextStyle(fontSize: screenWidth * 0.05), // Responsive font size
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.018,
            left: screenWidth * 0.15,
            child: Transform.rotate(
              angle: -0.3,
              child: Text(
                '🙁', 
                style: TextStyle(fontSize: screenWidth * 0.043), // Responsive font size
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.014,
            right: screenWidth * 0.06,
            child: Transform.rotate(
              angle: -0.2,
              child: Text(
                '🙂', 
                style: TextStyle(fontSize: screenWidth * 0.038), // Responsive font size
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.006,
            right: screenWidth * 0.15,
            child: Transform.rotate(
              angle: 0.25,
              child: Text(
                '😓', 
                style: TextStyle(fontSize: screenWidth * 0.025), // Responsive font size
              ),
            ),
          ),

          // RichText utama di tengah
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '\nIngin tahu rekap Mood kamu?\n',
                style: AppTypography.bodyText3.copyWith(
                  color: AppColors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Klik di sini! ',
                    style: AppTypography.bodyText3.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushNamed(
                          '/navbar',
                          arguments: {'initialIndex': 2},
                        );
                      },
                  ),
                  TextSpan(
                    text: '😊\n', 
                    style: TextStyle(fontSize: screenWidth * 0.03), // Responsive emoji size
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