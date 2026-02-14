import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  // Mock internal state
  UserModel? _mockUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _mockUser;

  // Init
  void init() {}

  // Auth state stream (Simulated)
  Stream<UserModel?> get authStateChanges async* {
    yield _mockUser;
  }

  Future<void> upgradeToPremium() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_mockUser != null) {
      _mockUser = _mockUser!.copyWith(subscriptionStatus: 'premium');
    }
  }

  // Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _mockUser = UserModel(
      id: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName ?? email.split('@')[0],
      createdAt: DateTime.now(),
      subscriptionStatus: 'trial',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    _isLoggedIn = true;
    return _mockUser!;
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _mockUser = UserModel(
      id: 'mock_uid_123',
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
      subscriptionStatus: 'free',
    );
    _isLoggedIn = true;
    return _mockUser!;
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));

    _mockUser = UserModel(
      id: 'mock_google_uid_456',
      email: 'google_user@example.com',
      displayName: 'Google User',
      photoUrl: 'https://via.placeholder.com/150',
      createdAt: DateTime.now(),
      subscriptionStatus: 'trial',
    );
    _isLoggedIn = true;
    return _mockUser!;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockUser = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Delete account
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    _mockUser = null;
    _isLoggedIn = false;
  }
}
