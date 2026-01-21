import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theworks/classes/auth_service.dart';
import 'package:theworks/routes.dart';
import 'package:theworks/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUsername() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: user.displayName);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Username'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result != user.displayName) {
      setState(() => _isLoading = true);
      try {
        await _authService.updateUsername(displayName: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating username: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final user = _authService.currentUser;
    if (user == null || user.email == null) return;

    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPassController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: newPassController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => v != null && v.length < 6
                    ? 'Min 6 characters'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (shouldUpdate == true) {
      setState(() => _isLoading = true);
      try {
        await _authService
            .resetPasswordFromCurrentPassword(
              email: user.email!,
              currentPassword: currentPassController.text,
              newPassword: newPassController.text,
            )
            .timeout(const Duration(seconds: 15)); // Add timeout to prevent hanging

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error updating password';
          if (e is FirebaseAuthException) {
            errorMessage = e.message ?? errorMessage;
          } else if (e is Exception) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure? This action is permanent. You will be asked to re-login to confirm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // For security, re-auth is often required before delete.
    // Here we'll just try the direct delete as in the original code,
    // but a proper flow would ask for credentials again.
    setState(() => _isLoading = true);

    try {
      await user.delete();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.welcome,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}. Try logging in again first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentGold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
          : ListView(
              children: [
                if (user != null) ...[
                  _buildSectionHeader('Account'),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text('Update Username',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(user.displayName ?? 'No username set',
                        style: const TextStyle(color: Colors.grey)),
                    onTap: _updateUsername,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.white),
                    title: const Text('Change Password',
                        style: TextStyle(color: Colors.white)),
                    onTap: _changePassword,
                  ),
                ],
                _buildSectionHeader('General'),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.white),
                  title: const Text('About', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Version 1.0.0',
                      style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.white)),
                  onTap: _signOut,
                ),
                _buildSectionHeader('Danger Zone'),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _deleteAccount,
                ),
              ],
            ),
    );
  }
}
