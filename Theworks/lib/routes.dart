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

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case welcome:
        return _page(const WelcomeScreen());
      case login:
        return _page(const LoginScreen());
      case register:
        return _page(const RegisterScreen());
      case tags:
        return _page(const TagsScreen());
      case additionalInfo:
        final args = s.arguments as List<String>?;
        return _page(AdditionalInfoScreen(selectedTags: args));
      case home:
        return _page(const HomeShell(), fullscreen: true);
      case projectDetail:
        final project = s.arguments as Project;
        return _page(ProjectDetailScreen(project: project));
      case createProject:
        return _page(const CreateProjectScreen());
      case settings:
        return _page(const SettingsScreen());
      case companySetup:
        return _page(const CompanySetupScreen());
      case createPost:
        return _page(const CreatePostScreen());
      case postDetail:
        final post = s.arguments as Post;
        return _page(PostDetailScreen(post: post));
      default:
        return _page(const WelcomeScreen());
    }
  }

  static PageRoute _page(Widget child, {bool fullscreen = false}) =>
      MaterialPageRoute(builder: (_) => child, fullscreenDialog: fullscreen);
}
