import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope( // blokkeer terug
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFCCBE96),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFCCBE96),
          elevation: 0,
          centerTitle: true,
          title: const Text('Log in', style: TextStyle(color: Color(0xFF303A5A))),
        ),
        body: const Center(child: Text('Login form hier')),
      ),
    );
  }
}
