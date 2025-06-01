import 'dart:developer';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komfy/features/profile/services/profile_services.dart';
import 'package:komfy/shared/widgets/custom_button.dart';
import 'package:komfy/themes/typography.dart';

import '../../../shared/icons/my_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final ProfileServices _profileServices = ProfileServices();
  late Future<Image?> _profilePicture;
  Map<String, dynamic> userInformation = {};
  Map<String, dynamic> userStats = {};
  Map<String, String> badgeAssets = {
    'Whisker' : 'assets/icons/whisker.svg',
    'Barker' : 'assets/icons/barker.svg',
    'Stride' : 'assets/icons/stride.svg',
    'Skye' : 'assets/icons/skye.svg',
  };
  Map<String, Color> badgeColors = {
    'Whisker' : Color(0xFFFFB800),
    'Barker' : Color(0xFFD19B61),
    'Stride' : Color(0xFFAF773F),
    'Skye' : Color(0xFFE3324B),
  };
  List<double> nextTargets = [];
  bool userInfoExists = false;
  bool _isLoading = true;
  double levelProgress = 0;
  String? _error;
  String _komfyBadge = 'None';

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  Future<void> _setUserStats() async {
    double nextTargetHariPemakaian = 0;
    double nextTargetJumlahJournal = 0;
    double nextTargetJumlahMoodTracker = 0;
    String currentBadgeName = userStats['komfyBadge']?.toString() ?? 'None';

    switch (currentBadgeName) {
      case 'None':
        nextTargetHariPemakaian = 3;
        nextTargetJumlahMoodTracker = 0;
        nextTargetJumlahJournal = 0;
        break;
      case 'Whisker':
        nextTargetHariPemakaian = 50;
        nextTargetJumlahMoodTracker = 30;
        nextTargetJumlahJournal = 0;
        break;
      case 'Barker':
        nextTargetHariPemakaian = 100;
        nextTargetJumlahMoodTracker = 0;
        nextTargetJumlahJournal = 35;
        break;
      case 'Stride':
        nextTargetHariPemakaian = 200;
        nextTargetJumlahMoodTracker = 50;
        nextTargetJumlahJournal = 35;
        break;
      case 'Skye':
        if(mounted) {
          setState(() {
            _komfyBadge = currentBadgeName;
            levelProgress = 1;
          });
          return;
        }
      default:
        log("Warning: Unknown komfyBadge '$currentBadgeName', defaulting to 'None' targets.");
        currentBadgeName = 'None';
        nextTargetHariPemakaian = 3;
        nextTargetJumlahMoodTracker = 0;
        nextTargetJumlahJournal = 0;
    }
    List<double> localNextTargets = [
      nextTargetHariPemakaian,
      nextTargetJumlahMoodTracker,
      nextTargetJumlahJournal,
    ];

    int activeTargetCount = 0;
    double targetHariPemakaianProgress = 0.0;
    double targetMoodTrackerProgress = 0.0;
    double targetJumlahJournalProgress = 0.0;

    double currentHariPemakaian = (userStats['hariPemakaian'] ?? 0.0).toDouble();
    double currentJumlahMoodTracker = (userStats['jumlahMoodTracker'] ?? 0.0).toDouble();
    double currentJumlahJournal = (userStats['jumlahJournal'] ?? 0.0).toDouble();

    if (nextTargetHariPemakaian > 0) {
      activeTargetCount++;
      targetHariPemakaianProgress = currentHariPemakaian / nextTargetHariPemakaian;
      targetHariPemakaianProgress = targetHariPemakaianProgress.clamp(0.0, 1.0);
    }

    if (nextTargetJumlahMoodTracker > 0) {
      activeTargetCount++;
      targetMoodTrackerProgress = currentJumlahMoodTracker / nextTargetJumlahMoodTracker;
      targetMoodTrackerProgress = targetMoodTrackerProgress.clamp(0.0, 1.0);
    }

    if (nextTargetJumlahJournal > 0) {
      activeTargetCount++;
      targetJumlahJournalProgress = currentJumlahJournal / nextTargetJumlahJournal;
      targetJumlahJournalProgress = targetJumlahJournalProgress.clamp(0.0, 1.0);
    }

    double calculatedLevelProgress = 0.0;
    if (activeTargetCount > 0) {
      calculatedLevelProgress = (targetHariPemakaianProgress +
          targetMoodTrackerProgress +
          targetJumlahJournalProgress) / activeTargetCount;
    } else {
      calculatedLevelProgress = 0.0;
    }

    if(calculatedLevelProgress >= 1.0) {
      await _profileServices.updateKomfyBadge();
      if (_komfyBadge == 'Skye'){
        return;
      }
      _setUserStats();
    }
    calculatedLevelProgress = calculatedLevelProgress.clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        _komfyBadge = currentBadgeName;
        nextTargets = localNextTargets;
        levelProgress = calculatedLevelProgress;

        log("--- Level Progress Calculation ---");
        log("Current Badge: $_komfyBadge");
        log("User Stats: hariPemakaian: $currentHariPemakaian, jumlahMoodTracker: $currentJumlahMoodTracker, jumlahJournal: $currentJumlahJournal");
        log("Next Targets: HP: $nextTargetHariPemakaian, MT: $nextTargetJumlahMoodTracker, J: $nextTargetJumlahJournal");
        log("Active Target Count: $activeTargetCount");
        log("Progress HP: $targetHariPemakaianProgress");
        log("Progress MT: $targetMoodTrackerProgress");
        log("Progress J: $targetJumlahJournalProgress");
        log("Calculated Level Progress: $levelProgress");
        log("---------------------------------");
      });
    }
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
      final stats = await _profileServices.getKomfyStats();
      final profilePicture = _profileServices.getBase64Image();
      setState(() {
        userInformation = data;
        userStats = stats;
        userInfoExists = userInformation.isNotEmpty;
        _profilePicture = profilePicture;
      });
      await _setUserStats();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching user information: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load user information.";
          userInfoExists = false;
          userStats = {};
          userInformation = {};
        });
        await _setUserStats();
        setState(() {
          _isLoading = false;
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
                  onPressed: _fetchUserInformation, // Retry button
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
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.1,
                  horizontal: screenWidth * 0.1,
                ),
                child: Column(
                  children: [
                    Text(
                      "Komfy",
                      textAlign: TextAlign.center,
                      style: AppTypography.title2.copyWith(
                        color: const Color(0xFF142553),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Stack(
                      children: [
                        FutureBuilder<Image?>(
                          future: _profilePicture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/komfy_badge');
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: badgeColors[_komfyBadge] ?? Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: screenHeight * 0.065,
                                      backgroundImage: snapshot.data!.image,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return InkWell(
                              onTap: () async {
                                Navigator.pushNamed(context, '/komfy_badge');
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: badgeColors[_komfyBadge] ?? Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: screenHeight * 0.065,
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD0E4FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/icons/round-profile.svg',
                                        width: screenHeight * 0.15,
                                        height: screenHeight * 0.15,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: SvgPicture.asset(
                              badgeAssets[_komfyBadge] ?? '',
                              height: 30,
                              width: 30,
                            ),
                            onPressed: () async {
                              Navigator.pushNamed(context, '/komfy_badge');
                            },
                            splashRadius: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                userInformation['namaPanggilan'],
                                style: AppTypography.subtitle2,
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(context, '/komfy_badge');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFF284082),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: LinearProgressIndicator(
                                    value: levelProgress,
                                    backgroundColor: Colors.white,
                                    color: badgeColors[_komfyBadge] ?? Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pushNamed(
                                        context,
                                        '/komfy_badge',
                                      );
                                    },
                                    child: Text(
                                      'Lihat Semua',
                                      style: AppTypography.bodyText3.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.pushNamed(
                                        context,
                                        '/komfy_badge',
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: SvgPicture.asset(
                                        'assets/icons/arrow-filled.svg',
                                        height: 15,
                                        width: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          userInfoExists
                              ? _buildUserInformation(context)
                              : _buildEmptyUserInformation(context),
                          SizedBox(height: screenHeight * 0.025),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return StatefulBuilder(
                                        builder:
                                            (context, setState) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              content: SizedBox(
                                                width: screenWidth * 0.9,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            24,
                                                            24,
                                                            24,
                                                            8,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Text(
                                                            "Yakin untuk log out?",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          SizedBox(height: 20),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      thickness: 1,
                                                      height: 1,
                                                      color: Color(0xFF366870),
                                                    ),
                                                    IntrinsicHeight(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              customBorder: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                            16.0,
                                                                          ),
                                                                    ),
                                                              ),
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                FirebaseAuth
                                                                    .instance
                                                                    .signOut();
                                                                Navigator.pushReplacementNamed(
                                                                  context,
                                                                  '/login',
                                                                );
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          16,
                                                                    ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  'Ya',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 1,
                                                            color: Color(
                                                              0xFF366870,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: InkWell(
                                                              customBorder: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.only(
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                            16.0,
                                                                          ),
                                                                    ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          16,
                                                                    ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  'Tidak',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
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
                                      );
                                    },
                                  );
                                },
                                text: 'Logout',
                                backgroundColor: Colors.transparent,
                                isInverted: true,
                                textColor: Colors.red,
                              ),
                              CustomButton(
                                onPressed: () async {
                                  final shouldRefresh =
                                      await Navigator.pushNamed(
                                        context,
                                        '/edit_profile',
                                      );
                                  if (shouldRefresh == true) {
                                    _fetchUserInformation();
                                  }
                                },
                                text: 'Edit Profile',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 60,
              right: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: Icon(MyIcons.setting),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUserInformation(BuildContext context) {
    return Column(
      children: [
        Text("No user information found.", style: AppTypography.bodyText1),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        _buildInfoRow('Username', '', context),
        _buildInfoRow('Email', '', context),
        _buildInfoRow('Nomor Telepon', '', context),
        _buildInfoRow('Tanggal Lahir', '', context),
        _buildInfoRow('Alamat', '', context),
      ],
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    return Column(
      children:
          userInformation.entries.map((entry) {
            String title = "";
            String value = entry.value.toString();

            switch (entry.key) {
              case 'namaPanggilan':
                title = 'Username';
                break;
              case 'email':
                title = 'Email';
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
            return _buildInfoRow(title, value, context);
          }).toList(),
    );
  }

  // Helper widget to build consistent rows
  Widget _buildInfoRow(String title, String value, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isLast = title == 'Alamat';
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          // Better for multi-line values
          children: [
            Text(title, style: AppTypography.subtitle4),
            const SizedBox(width: 10), // Add some spacing
            Expanded(
              // Allow value text to wrap
              child: Text(
                value.isNotEmpty ? value : '-', // Show a dash if value is empty
                style: AppTypography.bodyText2,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        !isLast
            ? Column(
              children: [
                SizedBox(height: screenHeight * 0.01),
                const Divider(thickness: 1),
                SizedBox(height: screenHeight * 0.005),
              ],
            ) // Adjusted spacing
            : SizedBox(height: screenHeight * 0.01),
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
}
