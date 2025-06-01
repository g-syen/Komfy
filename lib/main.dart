import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:komfy/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:komfy/core/navigation/app_router.dart';
import 'package:komfy/shared/screens/splash_screen.dart';


GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<bool> drawerStateNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KomfyApp());
}

class KomfyApp extends StatefulWidget {
  const KomfyApp({super.key});

  @override
  State<KomfyApp> createState() => _KomfyAppState();
}

class _KomfyAppState extends State<KomfyApp> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnState();
  }

  Future<void> _navigateBasedOnState() async {
    log("Checking onboarding and login status...");
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('seenOnBoardingScreen') ?? false;
    final bool isLoggedIn;
    if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) {
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }

    log("hasSeen: $hasSeen, isLoggedIn: $isLoggedIn");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = hasSeen
          ? (isLoggedIn ? '/navbar' : '/login')
          : '/onboarding';

      log("Navigating to: $route");
      navigatorKey.currentState?.pushReplacementNamed(route);
    });
  }


  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Komfy',
        theme: lightMode,
        onGenerateRoute: generateRoute,
        home: const SplashScreen(),
      ),
    );
  }
}