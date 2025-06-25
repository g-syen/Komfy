import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/encryption_services.dart';
import '../../../shared/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final String allowedDomains = 'student.ub.ac.id';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  DateTime? _lastBackPressed;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _friendlyErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Invalid email or incorrect password.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<void> _onLogin(UserCredential userCredential, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnBoardingScreen', true);
    getPrivateKeyFromFirestore(userCredential.user!.uid, password);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/navbar');
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final domain = email.split('@').last;

    if (!allowedDomains.contains(domain)) {
      setState(() {
        _error = 'Hanya email @$allowedDomains yang diperbolehkan.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: Text('Email Belum Terverifikasi'),
                  content: Text(
                    'Email anda belum diverifikasi. Kirim ulang email verifikasi?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          User? user = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              )
                              .then((cred) => cred.user);

                          await user?.sendEmailVerification();
                          await FirebaseAuth.instance.signOut();

                          if (mounted) {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text('Verifikasi Terkirim.'),
                                    content: Text(
                                      'Sebuah email verifikasi sudah dikirim ke alamat $email.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        } catch (e) {
                          log('Error resending email: $e');
                        }
                      },
                      child: Text('Resend'),
                    ),
                  ],
                ),
          );
        }
        return;
      } else {
        _onLogin(userCredential, password);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _friendlyErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          showToast('Press back again to exit', position: ToastPosition.bottom);
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Komfy',
                  style: GoogleFonts.josefinSans(
                    color: Color(0xFF142553),
                    fontSize: 50,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: 165,
                  height: 165,
                  child: Image.asset(
                    'assets/images/komfy_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.josefinSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CustomTextField(
                        textFieldController: _emailController,
                        hintText: 'Masukkan email',
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Password',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.josefinSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CustomTextField(
                        textFieldController: _passwordController,
                        hintText: 'Masukkan password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        obscureText: _obscurePassword,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/forgetpassword',
                      );
                    },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                      child: CustomButton(onPressed: _login, text: 'Login'),
                    ),

                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        endIndent: 10, // space after the line
                      ),
                    ),
                    Text('atau', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10, // space before the line
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Kamu belum punya akun?",
                      style: TextStyle(color: Colors.black.withAlpha(127)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
