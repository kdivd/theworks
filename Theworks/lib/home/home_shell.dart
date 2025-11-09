import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  final List<String>? selectedTags;

  const HomeShell({super.key, this.selectedTags});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  late final List<Widget> _pages;

  final Color _selectedItemColor = const Color(0xFF303A5A);
  final Color _unselectedItemColor = const Color(0xFF2D2C2B);
  final Color _backGroundColor = const Color(0xFFDEE0E2);

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(selectedTags: widget.selectedTags), // Pass tags to HomeTab
      const SearchTab(),
      const NotificationsTab(),
      const ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF303A5A),
        body: _pages[_i],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _i,
          onTap: (v) => setState(() => _i = v),
          selectedItemColor: _selectedItemColor,
          unselectedItemColor: _unselectedItemColor,
          backgroundColor: _backGroundColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
