import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komfy/features/profile/services/profile_services.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:komfy/themes/typography.dart';

import '../../../shared/icons/my_icons.dart';
import '../../../shared/widgets/alert_dialog.dart';
import '../../../shared/widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<EditProfileScreen> {
  final ProfileServices _profileServices = ProfileServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Image?> _profileImageFuture;
  bool? hasProfilePicture;
  Map<String, dynamic> userInformation = {};
  bool userInfoExists = false;
  bool _isLoading = true;
  String? _error;
  final Map<String, TextEditingController> _controllers = {};

  void _checkProfilePicture() async {
    final image = await _profileImageFuture;
    if (!mounted) return;
    setState(() {
      hasProfilePicture = image != null;
    });
  }

  Future<void> _updatePhotoProfile() async {
    await _profileServices.uploadCompressedProfilePicture();
    setState(() {
      _profileImageFuture = _profileServices.getBase64Image();
    });
    _checkProfilePicture();
  }

  // Future<void> _deletePhotoProfile() async {
  //   final currentUserId = _auth.currentUser!.uid;
  //   final docRef = _firestore.collection("Users").doc(currentUserId);
  //   setState(() {
  //     _error = '';
  //   });
  //
  //   try {
  //     await docRef.update({'photoProfile': FieldValue.delete()});
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Foto profil gagal dihapus.';
  //     });
  //   }
  // }

  Future<void> _updateProfile(
    String username,
    nomorTelepon,
    tanggalLahir,
    alamat,
  ) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    final currentUserId = _auth.currentUser!.uid;
    final docRef = _firestore.collection('Users').doc(currentUserId);
    try {
      final data = {
        'namaPanggilan': username,
        'nomorTelepon': nomorTelepon,
        'tanggalLahir': tanggalLahir,
        'alamat': alamat,
      };
      docRef.update(data);
      showDialog(
        context: context,
        builder: (_) {
          return StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 25),
                                  Icon(
                                    MyIcons.checkFill,
                                    color: Color(0xFF284082),
                                    size:
                                        MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Perubahan Tersimpan!",
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
                                    Navigator.pop(context, true);
                                  },
                                  icon: Icon(Icons.close, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          );
        },
      );
      log("Profile updated successfully.");
      setState(() {
        _isLoading = false;
        _error = null;
      });
      return;
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      log(e.toString());
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
    _profileImageFuture = _profileServices.getBase64Image();
    _checkProfilePicture();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchUserInformation() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _profileServices.getUserInformation();
      if (mounted) {
        setState(() {
          userInformation = data;
          userInfoExists = userInformation.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching user information: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load user information.";
          _isLoading = false;
          userInfoExists = false;
          userInformation = {};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (userInformation.isNotEmpty) {
      log(
        "User Information: ${userInformation.entries.map((entry) => '${entry.key}: ${entry.value}').toList()}",
      );
    } else {
      log("User Information is empty.");
    }

    if (_isLoading) {
      return Scaffold(body: _buildProfileSkeleton(context));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.1,
              horizontal: screenWidth * 0.1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchUserInformation,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.1,
              horizontal: screenWidth * 0.1,
            ),
            child: Column(
              children: [
                Text(
                  "Edit Profil",
                  textAlign: TextAlign.center,
                  style: AppTypography.title2,
                ),
                SizedBox(height: screenHeight * 0.01),
              InkWell(
                onTap: _updatePhotoProfile,
                child: FutureBuilder<Image?>(
                  future: _profileImageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: screenHeight * 0.07,
                              backgroundImage: snapshot.data!.image,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: IconButton(
                              icon: Icon(MyIcons.note),
                              onPressed: _updatePhotoProfile,
                            ),
                          ),
                        ],
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: screenHeight * 0.07,
                            backgroundColor: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/icons/round-profile.svg',
                              width: screenHeight * 0.15,
                              height: screenHeight * 0.15,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              alignment: Alignment.center,
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  MyIcons.note,
                                  color: Color(0xFF374957),
                                  size: 24,
                                ),
                                onPressed: _updatePhotoProfile,
                                splashRadius: 20,
                              ),
                            )
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),


              SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      _buildUserInformation(context),
                      SizedBox(height: screenHeight * 0.03),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            child: CustomButton(
                              onPressed: () async {
                                if (_isLoading) return;
                                final username =
                                    _controllers['namaPanggilan']?.text.trim();
                                final nomorTelepon =
                                    _controllers['nomorTelepon']?.text.trim();
                                final tanggalLahir =
                                    _controllers['tanggalLahir']?.text.trim();
                                final alamat =
                                    _controllers['alamat']?.text.trim();

                                _updateProfile(
                                  username!,
                                  nomorTelepon,
                                  tanggalLahir,
                                  alamat,
                                );
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
                                titleText: 'Hapus perubahan profile?',
                                confirmText: 'Ya',
                                cancelText: 'Tidak',
                                onConfirm: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context, true);
                                },
                                onCancel: () async {
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        child: Text(
                          'Batal',
                          style: AppTypography.subtitle4.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    return Column(
      children:
          userInformation.entries.map((entry) {
            if (entry.key == 'email') {
              return SizedBox();
            }
            String title = "";
            String value = entry.value.toString();

            switch (entry.key) {
              case 'namaPanggilan':
                title = 'Username';
                break;
              case 'nomorTelepon':
                title = 'Nomor Telepon';
                break;
              case 'tanggalLahir':
                title = 'Tanggal Lahir';
                break;
              case 'alamat':
                title = 'Alamat';
                break;
              default:
                title = entry.key;
            }

            // Create controller if not already created
            _controllers.putIfAbsent(
              entry.key,
              () => TextEditingController(text: value),
            );
            if (title == 'Tanggal Lahir') {
              return buildTanggalLahirField(
                context,
                _controllers[entry.key]!,
                title,
              );
            }
            return _buildInfoRow(title, _controllers[entry.key]!, context);
          }).toList(),
    );
  }

  // Helper widget to build consistent rows
  Widget _buildInfoRow(
    String title,
    TextEditingController textController,
    BuildContext context,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.subtitle4),
        CustomTextField(
          textFieldController: textController,
          hintText: 'Masukkan $title',
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildProfileSkeleton(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.1,
          horizontal: screenWidth * 0.1,
        ),
        child: Column(
          children: [
            Container(
              width: screenHeight * 0.15,
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            ...List.generate(
              5,
              (index) => Column(
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Divider(thickness: 1),
                  SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: 40,
                  color: Colors.white,
                ),
                Container(
                  width: screenWidth * 0.3,
                  height: 40,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTanggalLahirField(
    BuildContext context,
    TextEditingController tanggalLahirController,
    String title,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.subtitle4),
        TextField(
          controller: tanggalLahirController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: '',
            hintText: 'Masukan Tanggal Lahir',
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              tanggalLahirController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            }
          },
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}
