import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, unverified }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    // Listen to auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus _status = AuthStatus.initial;
  UserModel? _userProfile;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  User? get firebaseUser => _authService.currentUser;

  void _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
    } else if (!user.emailVerified) {
      _status = AuthStatus.unverified;
    } else {
      _status = AuthStatus.authenticated;
      _userProfile = await _authService.getUserProfile(user.uid);
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.unverified;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resendVerification() async {
    _setLoading(true);
    try {
      await _authService.resendVerificationEmail();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkVerification() async {
    _setLoading(true);
    try {
      final verified = await _authService.checkEmailVerified();
      if (verified) {
        _status = AuthStatus.authenticated;
        _userProfile = await _authService.getUserProfile(
            _authService.currentUser!.uid);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
