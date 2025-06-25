import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/icons/my_icons.dart';
import '../../../shared/widgets/number_list.dart';
import '../../../themes/typography.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<String> listFAQ = [
    "Apa itu Komfy?\nKomfy adalah aplikasi kesehatan mental yang menyediakan ruang aman untuk curhat, mendapatkan dukungan emosional, dan terhubung dengan ahli profesional.",
    "Apakah curhat di Komfy aman?\nTentu Saja! Privasimu adalah prioritas kami. Semua percakapan bersifat rahasia dan tidak akan dibagikan ke pihak lain.",
    "Apakah saya berbicara dengan manusia atau AI?\nKomfy memiliki chatbot AI untuk mendengarkan dan memberikan dukungan awal. Jika diperlukan, kamu juga bisa terhubung dengan tenaga profesional.",
    "Apakah ada komunitas atau forum diskusi?\nSaat ini, Komfy fokus pada sesi curhat individu. Namun, kami terus mengembangkan fitur baru untuk mendukung kesehatan mental pengguna.",
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 0, 0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(MyIcons.backButton),
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 26, 0, 0),
            child: Text('Kembali', style: AppTypography.subtitle3),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(MyIcons.about, size: 97, color: Color(0xFF284082)),
                        SizedBox(height: screenHeight * 0.05),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FAQ',
                              style: AppTypography.title2.copyWith(
                                color: Color(0xFF284082),
                              ),
                            ),
                            Text(
                              'Frequently Asked Questions',
                              style: AppTypography.subtitle3.copyWith(
                                color: Color(0xFF284082),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ],
                ),
              ),
              _buildFAQList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        NumberList(listFAQ, useDividers: true),
        SizedBox(height: screenHeight * 0.01),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apa FAQ ini cukup membantu?',
                style: AppTypography.subtitle4,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final firestore = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid);
                      final  data = {'faqRating': 'membantu'};
                      firestore.update(data);
                      showDialog(
                        context: context,
                        builder: (_) {
                          return StatefulBuilder(
                            builder:
                                (context, setState) => Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(MyIcons.thumbsUp),
                                        const SizedBox(width: 16),
                                        Text(
                                          'FAQ : membantu',
                                          style: AppTypography.subtitle2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 1),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Terima kasih atas feedback-mu!',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.subtitle4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(MyIcons.thumbsUp),
                  ),
                  IconButton(
                    onPressed: () async {
                      final firestore = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid);
                      final  data = {'faqRating': 'tidak membantu'};
                      firestore.update(data);
                      showDialog(
                        context: context,
                        builder: (_) {
                          return StatefulBuilder(
                            builder:
                                (context, setState) => Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(MyIcons.thumbsDown),
                                            const SizedBox(width: 16),
                                            Text(
                                              'FAQ : tidak membantu',
                                              style: AppTypography.subtitle2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(thickness: 1),
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'Terima kasih! Masukanmu akan jadi pertimbangan kami kedepannya.',
                                          textAlign: TextAlign.center,
                                          style: AppTypography.subtitle4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                      );
                    },
                    icon: Icon(MyIcons.thumbsDown),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
