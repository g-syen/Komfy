import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildImage(String assetName) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 60),
        Image.asset(
          'assets/images/komfy.png',
          width: 160, 
        ),
        Transform.translate(
          offset: const Offset(0, 130),
          child: Image.asset(
            'assets/images/$assetName',
            width: 340,
          ),
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

    return IntroductionScreen(
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
          image: _buildImage('onboarding1.png'),
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
          image: _buildImage('onboarding2.png'),
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
          image: _buildImage('onboarding3.png'),
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
    );
  }
}     