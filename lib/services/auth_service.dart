import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String _rememberMeKey = 'remember_me';

  bool _rememberMe = true;

  static Future<void> configurePersistence() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? true;

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    } else if (!rememberMe) {
      await FirebaseAuth.instance.signOut();
    }
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get rememberMe => _rememberMe;

  bool get isCurrentUserEmailVerified => _auth.currentUser?.emailVerified ?? false;

  bool get isCurrentUserPasswordProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((provider) => provider.providerId == 'password');
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-login-credentials':
        return 'Invalid email or password. Please check and try again.';
      case 'user-not-found':
        return 'No account found for this email. Please create an account.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked with another sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled before completion.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  Future<void> initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_rememberMeKey) ?? true;
    notifyListeners();
  }

  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
    if (kIsWeb) {
      await _auth.setPersistence(value ? Persistence.LOCAL : Persistence.SESSION);
    }
    notifyListeners();
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      await setRememberMe(rememberMe);
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!(credential.user?.emailVerified ?? false)) {
        await credential.user?.sendEmailVerification();
        await _auth.signOut();
        return 'Please verify your email first. We sent a verification link.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        await _auth.signInWithPopup(provider);
        return null;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign-in cancelled';
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      notifyListeners();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
