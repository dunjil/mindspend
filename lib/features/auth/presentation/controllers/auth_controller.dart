import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize mock repository
    _authRepository.init();

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      currentUser.value = user;
    });
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      currentUser.value = user;
      Get.offAll(() => const MainNavigation());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      currentUser.value = user;
      Get.offAll(() => const MainNavigation());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authRepository.signInWithGoogle();

      currentUser.value = user;
      Get.offAll(() => const MainNavigation());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Google Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      Get.back(); // Go back to login
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> upgradeToPremium() async {
    try {
      isLoading.value = true;
      await _authRepository.upgradeToPremium();

      // Update local state to reflect premium status
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          subscriptionStatus: 'premium',
        );
      } else {
        // Handle guest user getting premium
        currentUser.value = UserModel(
          id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          email: 'guest@mindspend.app',
          displayName: 'Guest Premium',
          createdAt: DateTime.now(),
          subscriptionStatus: 'premium',
        );
      }

      Get.snackbar(
        'Success',
        'Welcome to Premium! 🎉',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    currentUser.value = null;
    Get.offAll(() => const LoginPage());
  }
}
