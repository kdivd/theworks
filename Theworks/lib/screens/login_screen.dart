import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/auth_service.dart';
import '../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  String _NoEmail = "Don't have an account? Create account";
  bool _hidePw = true;
  bool _busy = false;

  static const Size _btnSize = Size(280, 48);

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  InputDecoration _filled(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: const Color(0xFF303A5A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    suffixIcon: suffix,
  );

  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
    fixedSize: _btnSize,
    shape: const StadiumBorder(),
    backgroundColor: const Color(0xFF303A5A),
    foregroundColor: Colors.white,
    elevation: 4,
    padding: EdgeInsets.zero,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  );

  @override
  Widget build(BuildContext context) {
    final supportsGoogle =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return PopScope(
      canPop: false, // blokkeer terug naar welcome
      child: Scaffold(
        backgroundColor: const Color(0xFFCCBE96),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔹 Logo bovenaan (met vaste hoogte voor consistentie)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Image.asset(
                        'assets/images/TESTLOGO.png',
                        height: 72,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(height: 72),
                      ),
                    ),

                    // 🔹 Titel onder het logo
                    const Text(
                      'Log into your account',
                      style: TextStyle(
                        color: Color(0xFF303A5A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 E-mail
                    SizedBox(
                      width: 300,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: _filled('Academy E-Mail'),
                              validator: (v) {
                                final text = v?.trim() ?? '';
                                if (text.isEmpty) return 'Enter your email';
                                if (!text.contains('@') ||
                                    !text.contains('.')) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // 🔹 Wachtwoord
                            TextFormField(
                              controller: _pw,
                              obscureText: _hidePw,
                              style: const TextStyle(color: Colors.white),
                              decoration: _filled(
                                'Password',
                                suffix: IconButton(
                                  onPressed: () =>
                                      setState(() => _hidePw = !_hidePw),
                                  icon: Icon(
                                    _hidePw
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final text = v ?? '';
                                if (text.length < 8) return 'Min. 8 characters';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Log in knop
                    ElevatedButton(
                      style: _btnStyle,
                      onPressed: _busy ? null : _login,
                      child: Text(_busy ? 'Please wait…' : 'Log in'),
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Google (verberg op desktop)
                    if (supportsGoogle)
                      ElevatedButton(
                        style: _btnStyle,
                        onPressed: _busy ? null : _googleSignIn,
                        child: const Text('Continue with Google'),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      style: _btnStyle,
                      child: const Text(
                        "Don't have an account? Create account",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await authService.value.signIn(
        email: _email.text.trim(),
        password: _pw.text,
      );
      _showError('Logged in successfully');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (_) {
      _showError('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _busy = true);
    try {
      // await authService.value.signInWithGoogle();      :TO DO FIX GOOGLE SIGN IN
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.tags);
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (_) {
      _showError('Google sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user is disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password. Try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
