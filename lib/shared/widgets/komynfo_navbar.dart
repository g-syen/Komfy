import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:komfy/features/komynfo/ui/article_content_screen.dart';
import 'package:komfy/features/komynfo/ui/video_content_screen.dart';
import 'package:komfy/features/komynfo/ui/komynfo_screen.dart';
import 'package:komfy/shared/icons/my_icons.dart';

class KomynfoNavbar extends StatefulWidget {
  const KomynfoNavbar({super.key});

  @override
  State<KomynfoNavbar> createState() => _KomynfoNavbarState();
}

class _KomynfoNavbarState extends State<KomynfoNavbar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    KomynfoScreen(),
    ArticleContentScreen(),
    VideoContentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Floating NavBar
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF142553),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: GNav(
                      gap: 5,
                      activeColor: Color(0xFF142553),
                      color: Colors.white,
                      tabBackgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      selectedIndex: _currentIndex,
                      onTabChange: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      tabs: const [
                        GButton(icon: MyIcons.asterik, text: 'Komynfo'),
                        GButton(icon: MyIcons.bacaanFill, text: 'Bacaan'),
                        GButton(icon: MyIcons.videoFill, text: 'Tontonan'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
