import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCBE96),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // voorkom crash als asset mist
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
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303A5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text('Log in'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303A5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
