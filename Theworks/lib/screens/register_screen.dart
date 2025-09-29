import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFCCBE96),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFCCBE96),
          elevation: 0,
          centerTitle: true,
          title: const Text('Create account', style: TextStyle(color: Color(0xFF303A5A))),
        ),
        body: const Center(child: Text('Register form hier')),
      ),
    );
  }
}
