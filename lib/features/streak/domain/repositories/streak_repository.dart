
import '../models/streak_model.dart';

abstract class StreakRepository {
  Future<StreakModel> getStreak();
  Future<void> updateStreak(DateTime logDate);
  Future<void> resetStreak();
}
