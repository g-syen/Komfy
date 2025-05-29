import 'package:flutter/material.dart';
import 'package:komfy/features/auth/ui/login_screen.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komfy/themes/typography.dart'; 

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);
  final Color primaryColor = const Color(0xFF284082);

  Future<void> _setSeenOnBoardingScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  Widget _buildPage({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.08, screenHeight * 0.07, screenWidth * 0.08, 0),
      child: Column(
        children: [
          Image.asset('assets/images/komfy.png', height: screenHeight * 0.07),
          SizedBox(height: screenHeight * 0.15),
          Image.asset(imagePath, height: screenHeight * 0.28),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title3.copyWith(
                    fontSize: screenWidth * 0.075,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.left,
            style: AppTypography.subtitle4.copyWith(
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        context: context,
        title: 'Sering Merasa Sendirian?',
        subtitle: 'Kamu tidak sendiri. Komfy siap menemani dan mendukungmu.',
        imagePath: 'assets/images/onboarding1.png',
      ),
      _buildPage(
        context: context,
        title: 'Butuh Teman Untuk Mendengarkan Cerita?',
        subtitle: 'Curhat tanpa takut dihakimi. Kami siap mendengar.',
        imagePath: 'assets/images/onboarding2.png',
      ),
      _buildPage(
        context: context,
        title: 'Ingin Mendapat Bantuan Ahli?',
        subtitle: 'Terhubung dengan profesional yang siap membantumu menemukan solusi terbaik.',
        imagePath: 'assets/images/onboarding3.png',
      ),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Onboarding(
            swipeableBody: pages,
            startIndex: 0,
            animationInMilliseconds: 500,
            onPageChanges: (_, __, index, ___) => currentIndexNotifier.value = index,
            buildHeader: (context, _, __, ___, ____, _____) => const SizedBox(height: 0),
            buildFooter: (context, _, pagesLength, __, setIndex, ___) {
              return ValueListenableBuilder<int>(
                valueListenable: currentIndexNotifier,
                builder: (context, index, _) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.07,
                    vertical: screenHeight * 0.035,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          pagesLength,
                          (i) => Container(
                            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                            width: i == index ? screenWidth * 0.07 : screenWidth * 0.025,
                            height: screenHeight * 0.012,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(i == index ? 20 : 50),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _setSeenOnBoardingScreen(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.012,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: AppTypography.bodyText1.copyWith(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
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
    );
  }
}