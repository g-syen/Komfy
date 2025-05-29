import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komfy/shared/widgets/custom_button.dart';

import '../../../shared/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<String> allowedDomains = ['ub.ac.id', 'student.ub.ac.id'];
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final domain = email.split('@').last;

    if (!allowedDomains.contains(domain)) {
      setState(() {
        _error = 'Only @${allowedDomains.join(" and @")} emails are allowed.';
      });
      return;
    }

    if (_confirmPasswordController.text!=_passwordController.text){
      setState(() {
        _error = 'Passwords do not match. Please check again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.sendEmailVerification();

      final data = {
        'email': email,
        'name': "",
        'role': 'user',
        'photoProfile': '',
        'public-key' : ''
      };
      _firestore.collection("Users").doc(userCredential.user!.uid).set(data);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Verify Your Email'),
            content: Text(
              'We’ve sent a verification email to $email. '
                  'Please verify your email before logging in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      log('Register error code: ${e.code}');
      setState(() {
        _error = _friendlyErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _friendlyErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Something went wrong. Try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 2),
              Padding(
                  padding: EdgeInsets.fromLTRB(16.0,0,16.0,0),
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
                      SizedBox(height: 16.0,),
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
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Confirm Password',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.josefinSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CustomTextField(
                        textFieldController: _confirmPasswordController,
                        hintText: 'Masukkan password kembali',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  )
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: EdgeInsets.fromLTRB(16.0,0,16.0,0),
                child: CustomButton(
                  onPressed: _register,
                  text: 'Create Account'
                ),
              ),


              SizedBox(height: 8,),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      endIndent: 10, // space after the line
                    ),
                  ),
                  Text(
                    'atau',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  Text("Kamu sudah punya akun?", style: TextStyle(color: Colors.black.withAlpha(127)),),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text("Masuk", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
