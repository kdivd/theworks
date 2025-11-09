import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createAccount(
      {required String email,
      required String password,
      required String displayName}) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    user.user!.updateDisplayName(displayName);
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String displayName}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.reload();
    }
  }

  Future<void> deleteAccount(
      {required String password, required String email}) async {
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword(
      {required String currentPassword,
      required String newPassword,
      required String email}) async {
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser?.reauthenticateWithCredential( credential);
    await currentUser?.updatePassword(newPassword);
  }
}
