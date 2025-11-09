import 'dart:io';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, Uint8List;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/auth_service.dart';
import '../routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final _displayName = TextEditingController(); // Added for display name
  XFile? _pickedProfileImage;

  bool _hidePw1 = true;
  bool _hidePw2 = true;
  bool _busy = false;

  static const Size _btnSize = Size(280, 48);

  @override
  void dispose() {
    _email.dispose();
    _pw1.dispose();
    _pw2.dispose();
    _displayName.dispose(); // Dispose display name controller
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // _profileImage = File(pickedFile.path); // OLD
        _pickedProfileImage = pickedFile; // NEW
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportsGoogle =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return PopScope(
      canPop: false, // geen back naar welcome
      child: Scaffold(
        backgroundColor: const Color(0xFFCCBE96),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFCCBE96),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF303A5A),
                      // UPDATED LOGIC HERE
                      backgroundImage: _pickedProfileImage != null
                          ? (kIsWeb
                          ? NetworkImage(_pickedProfileImage!.path) // For web
                          : FileImage(File(_pickedProfileImage!.path))) as ImageProvider // For mobile
                          : null,
                      child: _pickedProfileImage == null
                          ? const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white70,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Name
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

                  // Email
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _filled('Academy E-Mail'),
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

                  // Password
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

                  // Confirm Password
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

                  // Create account button
                  ElevatedButton(
                    style: _btnStyle,
                    onPressed: _busy ? null : _createAccount,
                    child: Text(_busy ? 'Please wait…' : 'Create account'),
                  ),

                  const SizedBox(height: 12),

                  // Google sign-up (hide on desktop)
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
      // 1. Create user with email and password
      // We use the standard FirebaseAuth method directly for clarity
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pw1.text,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed, user is null.');
      }

      String? imageUrl;

      // 2. Upload image IF one was picked
      if (_pickedProfileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.uid}.jpg');

        if (kIsWeb) {
          // Handle web upload
          Uint8List imageBytes = await _pickedProfileImage!.readAsBytes();
          await ref.putData(
              imageBytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          // Handle mobile upload
          await ref.putFile(File(_pickedProfileImage!.path));
        }

        // Get the URL after upload
        imageUrl = await ref.getDownloadURL();
      }

      // 3. Update profile with display name and photo URL
      // THIS IS THE FIX for the display name
      await user.updateDisplayName(_displayName.text.trim());

      if (imageUrl != null) {
        await user.updatePhotoURL(imageUrl);
      }

      // Reload user to get the updated info
      await user.reload();

      // Show a SUCCESS message (not an error)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.tags);
      debugPrint('account created');
    } on FirebaseAuthException catch (e) {
      _showError(_mapAuthError(e));
    } catch (e) {
      // This will print the exact error to your console (e.g., Storage permission denied)
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
    } on UnimplementedError {
      _showError('Google sign-in is not supported on this platform.');
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
