import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theworks/theme/app_colors.dart';
import '../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  final _displayName = TextEditingController();

  String _selectedRole = 'student'; // 'student' or 'recruiter'

  bool _hidePw1 = true;
  bool _hidePw2 = true;
  bool _busy = false;

  static const Size _btnSize = Size(280, 48);

  @override
  void dispose() {
    _email.dispose();
    _pw1.dispose();
    _pw2.dispose();
    _displayName.dispose();
    super.dispose();
  }

  InputDecoration _filled(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors.darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        suffixIcon: suffix,
      );

  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
        fixedSize: _btnSize,
        shape: const StadiumBorder(),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      );

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roleButton('student', 'Student', 'Looking for internship'),
        const SizedBox(width: 12),
        _roleButton('recruiter', 'Company', 'Looking for interns'),
      ],
    );
  }

  Widget _roleButton(String role, String label, String subLabel) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        width: 140,
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkBlue
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportsGoogle = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.accentGold,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.accentGold,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Create account',
            style: TextStyle(color: Color(0xFF303A5A)),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "What describes you best?",
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleSelector(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _displayName,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Colors.white),
                      decoration: _filled('Display Name'),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Enter your display name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _filled('E-Mail'),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Enter your email';
                        }
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _pw1,
                      obscureText: _hidePw1,
                      style: const TextStyle(color: Colors.white),
                      decoration: _filled(
                        'Password',
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePw1 = !_hidePw1),
                          icon: Icon(
                            _hidePw1 ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final text = v ?? '';
                        if (text.length < 8) {
                          return 'Min. 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _pw2,
                      obscureText: _hidePw2,
                      style: const TextStyle(color: Colors.white),
                      decoration: _filled(
                        'Confirm password',
                        suffix: IconButton(
                          onPressed: () => setState(() => _hidePw2 = !_hidePw2),
                          icon: Icon(
                            _hidePw2 ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v != _pw1.text) {
                          return 'Passwords don’t match';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: _btnStyle,
                    onPressed: _busy ? null : _createAccount,
                    child: Text(_busy ? 'Please wait…' : 'Create account'),
                  ),
                  const SizedBox(height: 12),
                  if (supportsGoogle)
                    ElevatedButton(
                      style: _btnStyle,
                      onPressed: _busy ? null : _googleSignIn,
                      child: const Text('Continue with Google'),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    child: const Text('Already have an account? Log in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pw1.text,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed, user is null.');
      }

      await user.updateDisplayName(_displayName.text.trim());
      await user.reload();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': _email.text.trim(),
        'displayName': _displayName.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Account created! Role: ${_selectedRole == 'recruiter' ? 'Company' : 'Student'}'),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      if (_selectedRole == 'recruiter') {
        // Recruiters (Companies) go to Company Setup
        Navigator.pushReplacementNamed(context, AppRoutes.companySetup);
      } else {
        // Students go to Tags screen
        Navigator.pushReplacementNamed(context, AppRoutes.tags);
      }

      debugPrint('account created as $_selectedRole');
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (e) {
      debugPrint('Error creating account: $e');
      _showError('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _busy = true);
    try {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.tags);
    } catch (_) {
      _showError('Google sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled.';
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
