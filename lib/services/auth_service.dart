import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await ensureUserProfile(
      user: credential.user,
      fallbackName: _nameFromEmail(email),
    );
    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (credential.user != null && name.trim().isNotEmpty) {
      await credential.user!.updateDisplayName(name.trim());
    }
    await ensureUserProfile(
      user: credential.user,
      fallbackName: name,
    );
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      await ensureUserProfile(
        user: credential.user,
        fallbackName: credential.user?.displayName,
      );
      return credential;
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final authCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final credential = await _auth.signInWithCredential(authCredential);
    await ensureUserProfile(
      user: credential.user,
      fallbackName: credential.user?.displayName,
    );
    return credential;
  }

  Future<ConfirmationResult> sendPhoneCodeWeb(String phoneNumber) {
    return _auth.signInWithPhoneNumber(phoneNumber.trim());
  }

  Future<void> ensureUserProfile({
    required User? user,
    String? fallbackName,
  }) async {
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final now = DateTime.now();
    final normalizedName =
        (user.displayName?.trim().isNotEmpty == true)
            ? user.displayName!.trim()
            : ((fallbackName?.trim().isNotEmpty == true)
                ? fallbackName!.trim()
                : 'Пользователь');

    if (!doc.exists) {
      await docRef.set({
        'name': normalizedName,
        'email': user.email,
        'phone': user.phoneNumber,
        'createdAt': Timestamp.fromDate(now),
        'registrationDate': Timestamp.fromDate(now),
        'tariffPlan': 'free',
        'updatedAt': Timestamp.fromDate(now),
      });
      return;
    }

    await docRef.set({
      'name': normalizedName,
      'email': user.email,
      'phone': user.phoneNumber,
      'updatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return doc.data();
    });
  }

  Future<void> updateProfileName({
    required User user,
    required String name,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;

    await user.updateDisplayName(normalized);
    await _firestore.collection('users').doc(user.uid).set({
      'name': normalized,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> updateAvatarUrl({
    required User user,
    required String avatarUrl,
  }) async {
    await user.updatePhotoURL(avatarUrl);
    await _firestore.collection('users').doc(user.uid).set({
      'avatarUrl': avatarUrl,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<void> updateEmail({
    required User user,
    required String newEmail,
  }) {
    return user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  Future<void> updatePassword({
    required User user,
    required String newPassword,
  }) {
    return user.updatePassword(newPassword);
  }

  Future<void> deleteAccount(User user) async {
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> signOut() => _auth.signOut();

  String _nameFromEmail(String email) {
    final normalized = email.trim();
    final at = normalized.indexOf('@');
    if (at <= 0) return 'Пользователь';
    return normalized.substring(0, at);
  }
}
