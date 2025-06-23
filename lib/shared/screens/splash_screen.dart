import 'dart:async';
import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 5), () {});

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Komfy',
              style: AppTypography.title1.copyWith(color: AppColors.darkBlue),
            ),
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/komfy_logo.png', height: 100,
            ),
            SizedBox(height: 24),
            Text(
              'Komfort for You',
              style: AppTypography.subtitle2.copyWith(color: AppColors.darkBlue),
            ),
          ],
        ),
      ),
    );
  }
}
