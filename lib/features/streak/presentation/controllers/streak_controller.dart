
import 'package:get/get.dart';
import '../../domain/models/streak_model.dart';
import '../../data/repositories/local_streak_repository.dart';

class StreakController extends GetxController {
  final LocalStreakRepository _repository = LocalStreakRepository();

  final Rx<StreakModel> streak = StreakModel.initial().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStreak();
  }

  Future<void> loadStreak() async {
    isLoading.value = true;
    try {
      final currentStreak = await _repository.getStreak();
      streak.value = currentStreak;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load streak');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStreakOnLog() async {
    try {
      await _repository.updateStreak(DateTime.now());
      await loadStreak(); // Reload to get updated streak
    } catch (e) {
      Get.snackbar('Error', 'Failed to update streak');
    }
  }

  Future<void> resetStreak() async {
    try {
      await _repository.resetStreak();
      await loadStreak();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset streak');
    }
  }
}
