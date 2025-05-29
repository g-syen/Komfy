import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komfy/themes/typography.dart'; 
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:komfy/shared/widgets/mood_selector.dart';
import 'package:komfy/shared/widgets/feature_carousel.dart';
import 'package:komfy/shared/widgets/komynfo_card.dart';
import '../../../shared/widgets/number_list.dart';
import 'package:komfy/shared/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMoodIndex = -1;

  final List<Map<String, dynamic>> eduCardItems = [
  {
    'title': "Familiar?\nInilah istilah mental health yang sering digunakan!",
    'image': 'assets/images/kesehatan_mental.png',
    'isVideo': false,
  },
  {
    'title': "Merasa emosional?\nItu tandanya kamu adalah manusia.",
    'image': 'assets/images/emosional.png',
    'isVideo': false,
  },
  {
    'title': "Tips regulasi stress untuk kestabilan mental",
    'image': 'assets/images/regulasi_stress.png',
    'isVideo': true,
  },
  {
    'title': "Lelah obatnya tidur aja? Kenali jenis lelah dan cara mengatasinya",
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
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
    body: SafeArea( 
      child: ListView(
        children: [
          _buildHeader(screenWidth),
          const SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Text(
                    "Gimana perasaan kamu saat ini?",
                    style: AppTypography.subtitle3,
                  ),
                ),
                MoodSelector(
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
                FeatureCarousel(),
                SizedBox(height: 10),
                Text(
                  "Terasa lebih baik jika kita kenal dengan diri sendiri!",
                  style: AppTypography.subtitle4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black), 
                ),
                SizedBox(height: 8),
                KomynfoCard(items: eduCardItems),
                _buildMoreSection(),
                const SizedBox(height: 10),
                _buildBottomInfo(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

  Widget _buildHeader(double width) {
    return Container(
      padding: EdgeInsets.only(
        top: width * 0.25,
        left: width * 0.1,
        right: width * 0.1,
        bottom: width * 0.05,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFD0E4FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Komfy",
            style: AppTypography.title1.copyWith(
              fontSize: width * 0.12,
              color: const Color(0xFF0B1956),
              height: 0.9,
            ),
          ),
          Text(
            "Hai, Jennie!",
            style: AppTypography.subtitle3.copyWith(
              fontSize: width * 0.05,
              color: const Color(0xFF0B1956),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSection() {
    final baseStyle = AppTypography.bodyText3.copyWith(
      color: const Color(0xFF374957),
    );

    return GestureDetector(
    onTap: () {},
    child: Padding(
      padding: const EdgeInsets.only(top: 10),
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
  );
}

void _showULTKSPDialog(BuildContext context) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.grow,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    alertPadding: const EdgeInsets.all(15),
    backgroundColor: Colors.white, 
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    titleStyle: AppTypography.subtitle2.copyWith(color: Colors.black),
    descStyle: AppTypography.subtitle3.copyWith(color: Colors.black),
  );

  Alert(
    context: context,
    style: alertStyle,
    buttons: [],
    content: Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 35, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Tutorial atur Jadwal Konseling",
                  style: AppTypography.subtitle2.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              NumberList(tutorialKonseling),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
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
          top: -8,
          left: -8,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    ),
  ).show();
}

Widget _buildBottomInfo() {
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
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        item['icon'],
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['description'],
                          style: AppTypography.bodyText4.copyWith(
                            color: const Color(0xFF142553),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item['title'],
                      style: AppTypography.bodyText4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF142553),
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

}