import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // één plek voor de knopmaat
  static const Size _btnSize = Size(280, 48);

  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
    fixedSize: _btnSize,                   // 🔒 vaste breedte + hoogte
    shape: const StadiumBorder(),         // ronde uiteinden zoals je design
    backgroundColor: const Color(0xFF303A5A),
    foregroundColor: Colors.white,
    elevation: 4,
    padding: EdgeInsets.zero,             // geen extra binnen-padding (maat blijft exact)
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCBE96),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/TESTLOGO.png',
              height: 100,
              errorBuilder: (_, __, ___) => const SizedBox(height: 100),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Welcome! We’re glad to help you on your journey",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color(0xFF303A5A)),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Log in (vast formaat)
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: _btnStyle,
              child: const Text('Log in'),
            ),
            const SizedBox(height: 12),

            // 🔹 Create account (vast formaat)
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
              style: _btnStyle,
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
