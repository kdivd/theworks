import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tags_screen.dart';
import 'home/home_shell.dart';

class AppRoutes {
  static const welcome  = '/';
  static const login    = '/login';
  static const register = '/register';
  static const tags     = '/tags';
  static const home     = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case welcome:  return _page(const WelcomeScreen());
      case login:    return _page(const LoginScreen());
      case register: return _page(const RegisterScreen());
      case tags:     return _page(const TagsScreen());
      case home:     return _page(const HomeShell(), fullscreen: true);
      default:       return _page(const WelcomeScreen());
    }
  }

  static PageRoute _page(Widget child, {bool fullscreen = false}) =>
      MaterialPageRoute(builder: (_) => child, fullscreenDialog: fullscreen);
}
