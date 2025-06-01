import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:komfy/core/navigation/app_router.dart';
import 'package:komfy/main.dart';
import 'package:komfy/themes/typography.dart';

class NavBar extends StatefulWidget {
  final int initialIndex;

  const NavBar({super.key, this.initialIndex = 0});

  @override
  NavBarState createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  late int _currentIndex;

  final List<String> _pageRoutes = [
    '/home',
    '/kommate',
    '/komfess',
    '/profile',
  ];

  final Color navBarColor = const Color(0xFFD0E4FF);
  final Color iconColor = const Color(0xFF0B1956);

  final List<String> activeIcons = [
    'assets/icons/home_active.svg',
    'assets/icons/chat_active.svg',
    'assets/icons/journal_active.svg',
    'assets/icons/profile_active.svg',
  ];

  final List<String> inactiveIcons = [
    'assets/icons/home.svg',
    'assets/icons/chat.svg',
    'assets/icons/journal.svg',
    'assets/icons/profile.svg',
  ];

  final List<String> labels = ['Beranda', 'Kommate', 'Komfess', 'Profil'];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _getWidgetFromRoute(String routeName, BuildContext context) {
    final builder = appRoutes[routeName];
    if (builder != null) {
      return builder(context);
    } else {
      return const Center(child: Text('Route not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final double iconSize = screenHeight * 0.03;
    final double fontSize = screenWidth * 0.03;


    return ValueListenableBuilder<bool>(
      valueListenable: drawerStateNotifier,
      builder: (context, isDrawerOpen, child) {
        return Scaffold(
          bottomNavigationBar:
          isDrawerOpen
              ? BottomBar(
            fit: StackFit.expand,
            borderRadius: BorderRadius.circular(20),
            duration: const Duration(seconds: 1),
            curve: Curves.decelerate,
            showIcon: true,
            width: 0,
            barColor: navBarColor,
            start: 2,
            end: 0,
            offset: 10,
            barAlignment: Alignment.bottomCenter,
            iconHeight: 38,
            iconWidth: 38,
            reverse: false,
            hideOnScroll: false,
            scrollOpposite: false,
            respectSafeArea: true,
            onBottomBarHidden: () {},
            onBottomBarShown: () {},
            body: (context, scrollController) {
              return _getWidgetFromRoute(
                _pageRoutes[_currentIndex],
                context,
              );
            },
            child: AnimatedSlide(
                offset: !isDrawerOpen ? Offset(0, 0) : Offset(0, 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                    opacity: !isDrawerOpen ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    child: SizedBox(
                      height: screenHeight * 0.07,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          final bool isActive = _currentIndex == index;

                          return GestureDetector(
                            onTap:
                                () => setState(() => _currentIndex = index),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (isActive)
                                  Container(
                                    height: 4,
                                    width: screenWidth * 0.12,
                                    decoration: BoxDecoration(
                                      color: iconColor,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(2),
                                        bottomRight: Radius.circular(2),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(height: 4),
                                SizedBox(height: screenHeight * 0.007),
                                SvgPicture.asset(
                                  isActive
                                      ? activeIcons[index]
                                      : inactiveIcons[index],
                                  height: iconSize,
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  labels[index],
                                  style: AppTypography.bodyText2.copyWith(
                                    color: iconColor,
                                    fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    )
                ),
            ),
          )
              : BottomBar(
            fit: StackFit.expand,
            borderRadius: BorderRadius.circular(20),
            duration: const Duration(seconds: 1),
            curve: Curves.decelerate,
            showIcon: true,
            width: screenWidth * 0.9,
            barColor: navBarColor,
            start: 2,
            end: 0,
            offset: 10,
            barAlignment: Alignment.bottomCenter,
            iconHeight: 38,
            iconWidth: 38,
            reverse: false,
            hideOnScroll: false,
            scrollOpposite: false,
            respectSafeArea: true,
            onBottomBarHidden: () {},
            onBottomBarShown: () {},
            body: (context, scrollController) {
              return _getWidgetFromRoute(
                _pageRoutes[_currentIndex],
                context,
              );
            },
            child: SizedBox(
              height: screenHeight * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  final bool isActive = _currentIndex == index;

                  return GestureDetector(
                    onTap:
                        () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (isActive)
                          Container(
                            height: 4,
                            width: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: iconColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 4),
                        SizedBox(height: screenHeight * 0.007),
                        SvgPicture.asset(
                          isActive
                              ? activeIcons[index]
                              : inactiveIcons[index],
                          height: iconSize,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        Text(
                          labels[index],
                          style: AppTypography.bodyText2.copyWith(
                            color: iconColor,
                            fontWeight:
                            isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            ),
        );
      },
    );
  }
}
