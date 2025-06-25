import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import '../../../shared/services/encryption_services.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../themes/typography.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String allowedDomains = 'student.ub.ac.id';
  final _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final nim = _nimController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if(email.isEmpty || nim.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _error = 'Pastikan semua data sudah terisi.';
      });
      return;
    }

    final domain = email.split('@').last;
    final fakultas = nim.substring(3, 6);

    if (!allowedDomains.contains(domain)) {
      setState(() {
        _error = 'Hanya email @$allowedDomains yang diperbolehkan.';
      });
      return;
    }

    if(!fakultas.contains('150')){
      setState(() {
        _error = 'Maaf, untuk saat ini aplikasi hanya dapat digunakan Mahasiswa FILKOM UB';
      });
      return;
    }

    if (_confirmPasswordController.text!=_passwordController.text){
      setState(() {
        _error = 'Kedua password tidak sama. Tolong periksa kembali.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      List<dynamic> keyList= await generateUserKeyPairs(userCredential.user!.uid, password);
      String publicKey = keyList[0];
      String base64EncryptedPrivateKey = base64Encode(keyList[1]);
      String iv = base64Encode(keyList[2]);
      String salt = base64Encode(keyList[3]);

      final data = {
        'nim': nim,
        'email': email,
        'publicKey' : publicKey,
        'encryptedPrivateKey': base64EncryptedPrivateKey,
        'iv': iv,
        'salt': salt,
        'role': 'user',
      };

      _firestore.collection("Users").doc(userCredential.user!.uid).set(data);

      if(mounted) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/complete_profile');
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
                style: AppTypography.title1.copyWith(color: Color(0xFF142553)),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
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
                        style: AppTypography.subtitle4,
                      ),
                      CustomTextField(
                        textFieldController: _emailController,
                        hintText: 'Masukkan email',
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'NIM',
                        textAlign: TextAlign.left,
                        style: AppTypography.subtitle4,
                      ),
                      CustomTextField(
                        textFieldController: _nimController,
                        hintText: 'Masukkan NIM',
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Password',
                        textAlign: TextAlign.left,
                        style: AppTypography.subtitle4,
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
                        style: AppTypography.subtitle4,
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
                    text: 'Buat Akun'
                ),
              ),


              SizedBox(height: 8,),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      endIndent: 10,
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
