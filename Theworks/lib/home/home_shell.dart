import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  // géén const voor de lijst zelf; wél const constructors binnenin
  final List<Widget> _pages = const [
    HomeTab(),
    SearchTab(),
    NotificationsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope( // vervangt WillPopScope
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF303A5A),
        body: _pages[_i],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _i,
          onTap: (v) => setState(() => _i = v),
          selectedItemColor: const Color(0xFF303A5A),
          unselectedItemColor: const Color(0xFF2D2C2B),
          backgroundColor: const Color(0xFFDEE0E2),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
