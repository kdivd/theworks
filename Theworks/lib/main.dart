import 'firebase_options.dart';
import 'package:theworks/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);
  }

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIVD Works',
      theme: ThemeData(
        fontFamily: 'KumbhSans',
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkBlue,
          primary: AppColors.darkBlue,
          secondary: AppColors.accentGold,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.accentGold,
          selectionColor: AppColors.offWhite,
          selectionHandleColor: AppColors.accentGold,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.offWhite,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accentGold,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentGold, width: 2),
          ),
          labelStyle: TextStyle(color: AppColors.darkBlue),
          floatingLabelStyle: TextStyle(color: AppColors.darkBlue),
        ),
      ),
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
