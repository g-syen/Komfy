import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komfy/shared/widgets/alert_dialog.dart';
import 'package:komfy/shared/widgets/custom_textfield.dart';
import '../../../shared/icons/my_icons.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../themes/typography.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<String> _reauthenticateUser({
    required String email,
    required String currentPassword,
    required BuildContext context,
  }) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cred = EmailAuthProvider.credential(email: email, password: currentPassword);

      await user?.reauthenticateWithCredential(cred);
      return 'Autentikasi Berhasil';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Kata sandi lama salah. Mohon periksa kembali.';
      } else {
        return 'Error autentikasi ulang. Silahkan coba lagi.';
      }
    }
  }

  Future<void> _onPasswordChange(String newPassword) async {
    try {
      if (_confirmPassword.text != _newPassword.text){
        setState(() {
          _error = 'Kedua password tidak sama. Tolong periksa kembali.';
        });
        return;
      }

      if (user != null) {
        if (_newPassword.text.length < 6) {
          setState(() {
            _error = 'Password terlalu pendek. Gunakan minimal 6 karakter.';
            _isLoading = false;
          });
          return;
        }
        await user?.updatePassword(newPassword);
        showDialog(context: context, builder: (_) {
          return StatefulBuilder(builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          8,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 25),
                            Icon(MyIcons.checkFill, color: Color(0xFF284082), size: MediaQuery.of(context).size.height * 0.1,),
                            SizedBox(height: 16),
                            Text(
                              "Password Tersimpan!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),

                      Positioned(
                        top: 10,
                        left: 10,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            padding: EdgeInsets.all(0.0),
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          );
        });
        print("Password updated successfully.");
        setState(() {
          _isLoading = false;
          _error = null;
        });
        return;
      } else {
        print("No user is currently signed in.");
        setState(() {
          _isLoading = false;
          _error = 'User tidak ditemukan';
        });
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
        setState(() {
          _isLoading = false;
          _error = 'User tidak berhasil autentikasi ulang';
        });
        return;
      } else {
        print('Password change error: ${e.message}');
        setState(() {
          _isLoading = false;
          _error = 'Ubah kata sandi tidak berhasil: ${e.message}';
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text('Atur ulang kata sandi', style: AppTypography.subtitle1),
                SizedBox(height: screenHeight * 0.02),
                Icon(MyIcons.passwordSolid, size: 97),
                SizedBox(height: screenHeight * 0.05),
                Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 0)
                  ,child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (_error != null) ...[
                        SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Masukkan sandi lama',
                        textAlign: TextAlign.left,
                        style: AppTypography.subtitle4,
                      ),
                      CustomTextField(
                        hintText: 'Masukkan Sandi Lama Anda',
                        textFieldController: _oldPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOldPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                        ),
                        obscureText: _obscureOldPassword,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Masukkan sandi baru',
                        textAlign: TextAlign.left,
                        style: AppTypography.subtitle4,
                      ),
                      CustomTextField(
                        hintText: 'Masukkan Sandi Baru',
                        textFieldController: _newPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        obscureText: _obscureNewPassword,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Konfirmasi sandi baru',
                        textAlign: TextAlign.left,
                        style: AppTypography.subtitle4,
                      ),
                      CustomTextField(
                        hintText: 'Konfirmasi Sandi Baru',
                        textFieldController: _confirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        obscureText: _obscureConfirmPassword,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: CustomButton(
                    onPressed: () async {
                      if (_isLoading) return;
                      String result = await _reauthenticateUser(
                        email: user!.email!,
                        currentPassword: _oldPassword.text.trim(),
                        context: context,
                      );

                      if (result == 'Autentikasi Berhasil') {
                        await _onPasswordChange(_newPassword.text.trim());
                      } else {
                        setState(() {
                          _isLoading = false;
                          _error = result;
                        });
                      }

                    },
                    text: 'Simpan perubahan',
                    width: screenWidth * 0.75,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return CustomAlertDialog(
                          screenWidth: screenWidth,
                          titleText: 'Batalkan perubahan kata sandi?',
                          confirmText: 'Ya',
                          cancelText: 'Tidak',
                          onConfirm: () async {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          onCancel: () async {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  child: Text('Batal', style: AppTypography.subtitle4.copyWith(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
