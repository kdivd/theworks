import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:theworks/theme/app_colors.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  List<Widget> _pages = [];
  static const Color _selectedItemColor = AppColors.darkBlue;
  static const Color _unselectedItemColor = Color(0xFF2D2C2B);
  static const Color _backGroundColor = AppColors.offWhite;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final selectedTags = args != null && args.containsKey('selectedTags')
          ? args['selectedTags'] as List<String>?
          : null;

      _pages = [
        HomeTab(selectedTags: selectedTags),
        const SearchTab(),
        const NotificationsTab(),
        const ProfileTab(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      // Should not happen given didChangeDependencies, but safe guard
      return const Center(child: CircularProgressIndicator());
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
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
