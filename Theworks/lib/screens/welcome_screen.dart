import 'package:flutter/material.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';
import 'package:theworks/theme/app_assets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Size _btnSize = Size(280, 48);

  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
        fixedSize: _btnSize,
        shape: const StadiumBorder(),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentGold,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.logo,
              height: 100,
              errorBuilder: (_, __, ___) => const SizedBox(height: 100),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Welcome! We’re glad to help you on your journey",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: AppColors.darkBlue),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Log in (vast formaat)
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              style: _btnStyle,
              child: const Text('Log in'),
            ),
            const SizedBox(height: 12),

            // 🔹 Create account (vast formaat)
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.register),
              style: _btnStyle,
              child: const Text('Create account'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
