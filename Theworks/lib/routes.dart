import 'package:flutter/material.dart';
import 'package:theworks/classes/project.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tags_screen.dart';
import 'home/home_shell.dart';
import 'screens/project_detail_screen.dart';
import 'screens/create_project_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/additional_info_screen.dart';
import 'package:theworks/classes/post.dart';
import 'package:theworks/screens/create_post_screen.dart';
import 'package:theworks/screens/post_detail_screen.dart';
import 'screens/company_setup_screen.dart';

import 'package:theworks/screens/user_profile_screen.dart'; // Import this

class AppRoutes {
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const tags = '/tags';
  static const home = '/home';
  static const projectDetail = '/project-detail';
  static const createProject = '/create-project';
  static const additionalInfo = '/additional-info';
  static const settings = '/settings';
  static const companySetup = '/company-setup';
  static const createPost = '/create-post';
  static const postDetail = '/post-detail';
  static const userProfile = '/user-profile'; // Add this

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case welcome:
        return _page(const WelcomeScreen(), settings: s);
      case login:
        return _page(const LoginScreen(), settings: s);
      case register:
        return _page(const RegisterScreen(), settings: s);
      case tags:
        return _page(const TagsScreen(), settings: s);
      case additionalInfo:
        final args = s.arguments as List<String>?;
        return _page(AdditionalInfoScreen(selectedTags: args), settings: s);
      case home:
        return _page(const HomeShell(), fullscreen: true, settings: s);
      case projectDetail:
        final project = s.arguments as Project;
        return _page(ProjectDetailScreen(project: project), settings: s);
      case createProject:
        final args = s.arguments;
        Project? project;
        if (args is Project) {
          project = args;
        }
        return _page(CreateProjectScreen(project: project), settings: s);
      case settings:
        return _page(const SettingsScreen(), settings: s);
      case companySetup:
        return _page(const CompanySetupScreen(), settings: s);
      case createPost:
        final post = s.arguments as Post?;
        return _page(CreatePostScreen(post: post), settings: s);
      case postDetail:
        final post = s.arguments as Post;
        return _page(PostDetailScreen(post: post), settings: s);
      case userProfile: // Add this case
        final userData = s.arguments as Map<String, dynamic>;
        return _page(UserProfileScreen(userData: userData), settings: s);
      default:
        return _page(const WelcomeScreen(), settings: s);
    }
  }

  static PageRoute _page(Widget child,
          {bool fullscreen = false, RouteSettings? settings}) =>
      MaterialPageRoute(
          builder: (_) => child,
          fullscreenDialog: fullscreen,
          settings: settings);
}
