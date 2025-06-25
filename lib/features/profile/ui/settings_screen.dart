import 'package:flutter/material.dart';
import 'package:komfy/features/profile/services/profile_services.dart';
import 'package:komfy/shared/widgets/alert_dialog.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:komfy/themes/typography.dart';

import '../../../shared/icons/my_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileServices _profileServices = ProfileServices();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 0, 0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(MyIcons.backButton),
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 26, 0, 0),
            child: Text('Kembali', style: AppTypography.subtitle3),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Pengaturan', style: AppTypography.title2),
              SizedBox(height: screenHeight * 0.02),
              Icon(MyIcons.setting, size: 97),
              SizedBox(height: screenHeight * 0.05),
              CustomButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/komfy_badge');
                },
                text: 'Komfy Badge Saya',
                width: screenWidth * 0.75,
                leadingIcon: SizedBox(
                  width: 20,
                  child: Image.asset(
                    'assets/images/cat.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/change_password');
                },
                text: 'Atur Ulang Kata Sandi',
                width: screenWidth * 0.75,
                leadingIcon: Icon(
                  MyIcons.lock,
                  color: Color(0xFF284082),
                  size: 15,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/faq');
                },
                text: 'FAQ',
                width: screenWidth * 0.75,
                leadingIcon: Icon(MyIcons.about, color: Color(0xFF284082)),
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return CustomAlertDialog(
                        screenWidth: screenWidth,
                        titleText: 'Kamu yakin ingin menghapus akun?',
                        subtitleText:
                            'Menghapus akun akan menghilangkan data selamanya.',
                        confirmText: 'Ya',
                        cancelText: 'Tidak',
                        switchColor: true,
                        onCancel: () async {
                          Navigator.pop(context);
                        },
                        onConfirm: () async {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return CustomAlertDialog(
                                screenWidth: screenWidth,
                                titleText: 'Akun beserta data akun akan tidak dapat dikembalikan setelah dihapus.',
                                confirmText: 'Hapus Akun',
                                cancelText: 'Batal',
                                switchColor: true,
                                onConfirm: () async {
                                  bool isDeleted = await _profileServices.deleteAccount();
                                  if (isDeleted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Akun berhasil dihapus.")),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Akun gagal dihapus.")),
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                                onCancel: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
                text: 'Hapus Akun',
                backgroundColor: Colors.white,
                textColor: Colors.red,
                isInverted: true,
                borderColor: Colors.red,
                width: screenWidth * 0.75,
                leadingIcon: Icon(MyIcons.trashcanFill),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
