import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komfy/onboarding.dart';
import 'package:komfy/loginpage.dart';
import 'package:komfy/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkFirstSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Komfy',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Color(0xFF6F8BBD),
        textTheme: GoogleFonts.josefinSansTextTheme(),
      ),
      routes: {
        '/onboarding': (context) => const OnBoarding(),
        '/login' : (context) => const LoginPage(),
        '/home': (context) => const Homepage(),
      },
      home: FutureBuilder<bool>(
        future: checkFirstSeen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final hasSeen = snapshot.data ?? false;
              Navigator.pushReplacementNamed(
                context,
                hasSeen ? '/login' : '/onboarding',
              );
          });
          return const Scaffold(
              body: SizedBox(),
            );
        }
      },
      ),
    );
  }
}
