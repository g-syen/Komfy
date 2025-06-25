import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komfy/features/profile/services/profile_services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/icons/my_icons.dart';
import '../../../themes/typography.dart';

class KomfyBadgeScreen extends StatefulWidget {
  const KomfyBadgeScreen({super.key});

  @override
  State<KomfyBadgeScreen> createState() => _KomfyBadgeScreenState();
}

class _KomfyBadgeScreenState extends State<KomfyBadgeScreen> {
  final ProfileServices _profileServices = ProfileServices();
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
      if (mounted) {
        setState(() {
          userInformation = data;
          userStats = stats;
          userInfoExists = userInformation.isNotEmpty;
        });
        await _setUserStats();
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
        setState(() {
          _komfyBadge = currentBadgeName;
          levelProgress = 1;
        });
        return;
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
      _fetchUserInformation();
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Future<Image?> _userProfilePicture = _profileServices.getBase64Image();

    if (_isLoading) {
      return _buildKomfyBadgeSkeleton(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD0E4FF),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFD0E4FF),
      body: SafeArea(
        bottom: true,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(color: Color(0xFFD0E4FF)),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.23,
                child: Column(
                  children: [
                    FutureBuilder<Image?>(
                      future: _userProfilePicture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: badgeColors[_komfyBadge] ?? Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: screenHeight * 0.065,
                                backgroundImage: snapshot.data!.image,
                              ),
                            ),
                          );
                        }

                        return Padding(
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
                              )
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Container(
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.065,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFF091F58),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/streak.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Streak Day',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          userStats['hariPemakaian'].toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(width: 1, color: Colors.white),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Komfy Badge',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _komfyBadge,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.23,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Color(0xFF091F5B),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 2), child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(badgeAssets[_komfyBadge] ?? '', width: 15, height: 15,),
                                  SizedBox(width: 12),
                                  Text(_komfyBadge, style: AppTypography.bodyText1.copyWith(color: Colors.white),),
                                ],
                              ),
                              Text('Terus gunakan Komfy untuk level up!', style: AppTypography.bodyText4.copyWith(color: Colors.white),)
                            ],
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 16, 25),
                            child: Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                backgroundColor: Colors.white,
                                color: badgeColors[_komfyBadge] ?? Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: _buildKomfyBadges(),
                          ),
                          _buildKomfyDays(),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: Text(
                              'Tingkat Badge Komfy',
                              style: AppTypography.subtitle2.copyWith(
                                color: Color(0xFF284082),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: _buildKomfyBadgeTiers(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKomfyBadgeTiers() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/icons/whisker.svg', height: 50, width: 50),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Whisker',
                    style: AppTypography.bodyText1.copyWith(
                      color: Color(0xFF284082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kamu telah memakai aplikasi selama 3 hari berturut-turut!',
                    style: AppTypography.bodyText3,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            SvgPicture.asset('assets/icons/barker.svg', height: 50, width: 50),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barker',
                    style: AppTypography.bodyText1.copyWith(
                      color: Color(0xFF284082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kamu telah memakai aplikasi selama 50 hari berturut-turut dan mengisi mood tracker 30 kali!',
                    style: AppTypography.bodyText3,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            SvgPicture.asset('assets/icons/stride.svg', height: 50, width: 50),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stride',
                    style: AppTypography.bodyText1.copyWith(
                      color: Color(0xFF284082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kamu telah memakai aplikasi selama 100 hari berturut-turut dan menulis 35 jurnal!',
                    style: AppTypography.bodyText3,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Row(
          children: [
            SvgPicture.asset('assets/icons/skye.svg', height: 50, width: 50),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skye',
                    style: AppTypography.bodyText1.copyWith(
                      color: Color(0xFF284082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kamu telah memakai aplikasi selama 200 hari berturut-turut, mengisi 50 mood tracker dan menulis 35 jurnal!',
                    style: AppTypography.bodyText3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKomfyDays() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '3 hari',
          style: AppTypography.subtitle4.copyWith(color: Color(0xFF284082)),
        ),
        SizedBox(width: screenWidth * 0.11),
        Text(
          '50 hari',
          style: AppTypography.subtitle4.copyWith(color: Color(0xFF284082)),
        ),
        SizedBox(width: screenWidth * 0.095),
        Text(
          '100 hari',
          style: AppTypography.subtitle4.copyWith(color: Color(0xFF284082)),
        ),
        SizedBox(width: screenWidth * 0.07),
        Text(
          '200 hari',
          style: AppTypography.subtitle4.copyWith(color: Color(0xFF284082)),
        ),
      ],
    );
  }

  Widget _buildKomfyBadges() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/whisker.svg', height: 30, width: 30),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFFFB800),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFFB800), Color(0xFFD19B61)],
            ),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFD19B61),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        SvgPicture.asset('assets/icons/barker.svg', height: 30, width: 30),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFD19B61),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFD19B61), Color(0xFFAF773F)],
            ),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFAF773F),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        SvgPicture.asset('assets/icons/stride.svg', height: 30, width: 30),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFAF773F),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFAF773F), Color(0xFFE3324B)],
            ),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            color: Color(0xFFE3324B),
            shape: StarBorder(
              points: 5.00,
              rotation: 0.00,
              innerRadiusRatio: 0.40,
              pointRounding: 0.00,
              valleyRounding: 0.00,
              squash: 0.00,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        SvgPicture.asset('assets/icons/skye.svg', height: 30, width: 30),
      ],
    );
  }

  Widget _buildKomfyBadgeSkeleton(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final Color baseColor = Colors.grey.shade300;
    final Color highlightColor = Colors.grey.shade100;// For text-like placeholders

    Widget skeletonContainer(double? width, double height, {double borderRadius = 4.0, EdgeInsetsGeometry? margin, BoxShape shape = BoxShape.rectangle}) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer needs a non-transparent base for effect
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
          shape: shape,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar( // AppBar structure similar to the original
        backgroundColor: Color(0xFFD0E4FF),
        leading: Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 0, 0),
          child: Icon(MyIcons.backButton, color: Colors.grey), // Placeholder icon
        ),
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 26, 0, 0),
          child: skeletonContainer(screenWidth * 0.2, 20), // Placeholder for "Kembali"
        ),
      ),
      backgroundColor: Color(0xFFD0E4FF), // Match screen background
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SafeArea(
          bottom: true,
          child: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Top Blue Area Skeleton
                Container(
                  decoration: BoxDecoration(color: Color(0xFFD0E4FF)), // This is the actual bg, shimmer works on children
                  alignment: Alignment.center,
                  width: screenWidth,
                  height: screenHeight * 0.23,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Align items for consistent skeleton
                    children: [
                      skeletonContainer(screenHeight * 0.13, screenHeight * 0.13, shape: BoxShape.circle), // Profile Pic
                      SizedBox(height: screenHeight * 0.01),
                      // Stats Box Skeleton
                      Container( // Mimic the dark blue rounded box
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.065,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white, // Shimmer base
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    skeletonContainer(20, 20, shape:BoxShape.circle),
                                    SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        skeletonContainer(screenWidth * 0.15, 14),
                                        SizedBox(height: 4),
                                        skeletonContainer(screenWidth * 0.1, 12),
                                      ],
                                    )
                                  ],
                                )
                            ),
                            Container(width: 1, height: double.infinity, color: baseColor, margin: EdgeInsets.symmetric(horizontal:8)),
                            Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    skeletonContainer(screenWidth * 0.2, 14),
                                    SizedBox(height: 4),
                                    skeletonContainer(screenWidth * 0.15, 12),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // First Positioned Container Skeleton (Dark Blue Background - progress section)
                Positioned(
                  top: screenHeight * 0.23,
                  left: 0,
                  right: 0,
                  // Approximate height or let it be determined by child for skeleton
                  height: screenHeight * 0.12, // Adjusted based on content
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white, // Shimmer base
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 8), // Adjusted padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  skeletonContainer(15, 15, shape: BoxShape.circle),
                                  SizedBox(width: 12),
                                  skeletonContainer(screenWidth * 0.2, 16),
                                ],
                              ),
                              skeletonContainer(screenWidth * 0.3, 12),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 16, 0), // No bottom padding for progress bar
                          child: skeletonContainer(null, 10, borderRadius: 8), // LinearProgressIndicator skel
                        ),
                      ],
                    ),
                  ),
                ),

                // Second Positioned Container Skeleton (White Background - main content area)
                Positioned(
                  top: screenHeight * 0.33, // Adjusted top based on the layer above
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white, // Shimmer base
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: SingleChildScrollView( // Important for long content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _buildKomfyBadges Skeleton
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(7, (i) => // Approx 4 badges + 3 sets of stars
                              skeletonContainer(i % 2 == 0 ? 30 : 10, i % 2 == 0 ? 30 : 10, shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle)
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // _buildKomfyDays Skeleton
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(4, (_) => skeletonContainer(screenWidth * 0.15, 14)),
                          ),
                          SizedBox(height: 24),
                          // "Tingkat Badge Komfy" title Skeleton
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: skeletonContainer(screenWidth * 0.5, 20),
                          ),
                          // _buildKomfyBadgeTiers Skeleton
                          Column(
                            children: List.generate(4, (_) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    skeletonContainer(50, 50, shape: BoxShape.circle),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          skeletonContainer(null, 16, margin: EdgeInsets.only(bottom: 6)),
                                          skeletonContainer(null, 12),
                                          SizedBox(height: 4),
                                          skeletonContainer(screenWidth * 0.5, 12), // Second line of desc
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
