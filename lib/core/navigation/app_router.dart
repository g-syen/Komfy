import 'package:flutter/material.dart';
import 'package:komfy/features/onboarding/onboarding_screen.dart';
import 'package:komfy/features/auth/ui/login_screen.dart';
import 'package:komfy/features/auth/ui/register_screen.dart';
import 'package:komfy/features/home/home_screen.dart';
import 'package:komfy/features/kommate/ui/kommate_screen.dart';

Map<String, WidgetBuilder> appRoutes = {
  // '/forgetpassword': (context) => ForgetpasswordScreen(),
  '/kommate': (context) => KommateScreen(),
  '/register': (context) => const RegisterScreen(),
  '/onboarding': (context) => const OnBoardingScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
};