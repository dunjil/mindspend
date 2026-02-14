import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../../data/repositories/gamification_repository.dart';

class GamificationController extends GetxController {
  final GamificationRepository _repository = GamificationRepository();
  final RxInt currentPoints = 0.obs;
  final RxInt currentLevel = 1.obs;

  // Confetti controller for celebrations
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadData();
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }

  Future<void> _loadData() async {
    currentPoints.value = await _repository.getPoints();
    currentLevel.value = await _repository.getLevel();
  }

  int get nextLevelPoints => currentLevel.value * 100;
  double get progress => currentPoints.value / nextLevelPoints;

  Future<void> addPoints(int points) async {
    int newPoints = currentPoints.value + points;
    int nextLevelThreshold = nextLevelPoints;

    if (newPoints >= nextLevelThreshold) {
      // Level Up!
      newPoints -= nextLevelThreshold;
      currentLevel.value++;
      await _repository.saveLevel(currentLevel.value);
      _showLevelUpDialog();
      confettiController.play();
    }

    currentPoints.value = newPoints;
    await _repository.savePoints(newPoints);
  }

  void _showLevelUpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 LEVEL UP! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You reached Level ${currentLevel.value}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
