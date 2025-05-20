import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnBoardingScreen', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildImage(String assetName, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.05),
        Image.asset(
          'assets/images/komfy.png',
          width: screenWidth * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.04),
        Image.asset(
          'assets/images/$assetName',
          width: screenWidth * 0.8,
          height: screenHeight * 0.25,
          fit: BoxFit.contain,
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      bodyAlignment: Alignment.topLeft,
      titlePadding: const EdgeInsets.only(left: 40, right: 60, top: 0),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      pageColor: Color(0xFFF4F9FF),
      contentMargin: const EdgeInsets.only(top: 110),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: const Color(0xFFF4F9FF),
        pages: [
          PageViewModel(
            titleWidget: Align(
              alignment: Alignment.topLeft,
              child: Text("Sering Merasa Sendirian?",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, height: 1.1, color: Colors.black,
                ),
              ),
            ),
            bodyWidget: Text(
              "Kamu tidak sendiri. Komfy siap menemani dan mendukungmu.",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, height: 1.25, color: Colors.black),
            ),
            image: _buildImage('onboarding1.png', context),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Align(
              alignment: Alignment.topLeft,
              child: Text("Butuh Teman Untuk Mendengarkan Cerita?",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, height: 1.1, color: Colors.black,
                ),
              ),
            ),
            bodyWidget: Text(
              "Curhat tanpa takut dihakimi. Kami siap mendengar.",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, height: 1.25, color: Colors.black),
            ),
            image: _buildImage('onboarding2.png', context),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: Align(
              alignment: Alignment.topLeft,
              child: Text("Ingin Mendapat Bantuan Ahli?",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, height: 1.1, color: Colors.black,
                ),
              ),
            ),
            bodyWidget: Text(
              "Terhubung dengan profesional yang siap membantumu menemukan solusi terbaik.",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, height: 1.25, color: Colors.black),
            ),
            image: _buildImage('onboarding3.png', context),
            decoration: pageDecoration,
          ),
        ],
        showSkipButton: false,
        showNextButton: false,
        showDoneButton: false,
        isProgressTap: false,
        isProgress: false,
        globalFooter: Builder(
            builder: (context){
              final controller = introKey.currentState?.controller ?? PageController();
              return Padding(
                padding: const EdgeInsets.fromLTRB(27, 16, 27, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Color(0xFF284082),
                        dotColor: Color(0xFF284082),
                        dotHeight: 10,
                        dotWidth: 10,
                        expansionFactor: 2.5,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onIntroEnd,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: const Color(0xFF284082),
                        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 7),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
      )
    );
  }
}     