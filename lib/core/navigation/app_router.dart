import 'package:flutter/material.dart';
import 'package:komfy/features/onboarding/onboarding_screen.dart';
import 'package:komfy/shared/widgets/navbar.dart';
import 'package:komfy/features/auth/ui/login_screen.dart';
import 'package:komfy/features/auth/ui/register_screen.dart';
import 'package:komfy/features/home/home_screen.dart';
import 'package:komfy/features/kommate/ui/kommate_screen.dart';
import 'package:komfy/features/moodtracker/mood_recap_screen.dart';
import 'package:komfy/features/moodtracker/mood_input_screen.dart';
import 'package:komfy/features/moodtracker/mood_input_screen2.dart';
import 'package:komfy/features/moodtracker/mood_input_screen3.dart';
import 'package:komfy/features/moodtracker/mood_story_screen.dart';
import 'package:komfy/features/moodtracker/model/mood_session_model.dart';
import 'package:komfy/features/profile.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/onboarding': (context) => OnBoardingScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  // '/forgetpassword': (context) => ForgetpasswordScreen(),
  '/home': (context) => const HomeScreen(),
  '/kommate': (context) => KommateScreen(),
  '/komfess': (context) => const MoodRecapScreen(),
  '/navbar': (context) => const NavBar(),
  '/mood_input': (context) => MoodInputScreen(),
  '/profile': (_) => const Profile(),
};

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/navbar':
      final args = settings.arguments as Map<String, dynamic>?;
      final index = args?['initialIndex'] ?? 0;
      return MaterialPageRoute(
        builder: (_) => NavBar(initialIndex: index),
      );
    case '/mood_input2':
      final args = settings.arguments as Map<String, dynamic>;
      final moodSession = args['moodSession'] as MoodSession;
      final currentStep = args['currentStep'] as int;
      return MaterialPageRoute(
        builder: (_) => MoodInputScreen2(
          moodSession: moodSession,
          currentStep: currentStep,
        ),
      );
    case '/mood_input3':
      final args = settings.arguments as Map<String, dynamic>;
      final moodSession = args['moodSession'] as MoodSession;
      final currentStep = args['currentStep'] as int;
      return MaterialPageRoute(
        builder: (_) => MoodInputScreen3(
          moodSession: moodSession,
          currentStep: currentStep,
        ),
      );
    case '/mood_story':
      final args = settings.arguments as Map<String, dynamic>;
      final moodSession = args['moodSession'] as MoodSession;
      final currentStep = args['currentStep'] as int;
      return MaterialPageRoute(
        builder: (_) => MoodStoryScreen(
          moodSession: moodSession,
          currentStep: currentStep,
        ),
      );
    default:
      if (appRoutes.containsKey(settings.name)) {
        return MaterialPageRoute(builder: appRoutes[settings.name]!);
      }
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('404 - Route not found')),
        ),
      );
  }
}