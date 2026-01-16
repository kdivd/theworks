import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/notification_service.dart';
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
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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

  Widget _buildNotificationIcon() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Icon(Icons.notifications);

    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService().getUserNotifications(user.uid),
      builder: (context, snapshot) {
        bool hasUnread = false;
        if (snapshot.hasData) {
          hasUnread = snapshot.data!.docs.any((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['read'] == false;
          });
        }

        if (hasUnread) {
          return Stack(
            children: [
              const Icon(Icons.notifications),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              )
            ],
          );
        }
        return const Icon(Icons.notifications);
      },
    );
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
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: _buildNotificationIcon(), label: 'Alerts'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
