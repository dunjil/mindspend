
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/streak_model.dart';
import '../../domain/repositories/streak_repository.dart';

class LocalStreakRepository implements StreakRepository {
  static const String _streakKey = 'streak_data';

  @override
  Future<StreakModel> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streakJson = prefs.getString(_streakKey);
    
    if (streakJson == null) {
      return StreakModel.initial();
    }
    
    return StreakModel.fromJson(json.decode(streakJson));
  }

  @override
  Future<void> updateStreak(DateTime logDate) async {
    final currentStreak = await getStreak();
    final newStreak = _calculateNewStreak(currentStreak, logDate);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_streakKey, json.encode(newStreak.toJson()));
  }

  @override
  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_streakKey);
  }

  StreakModel _calculateNewStreak(StreakModel current, DateTime logDate) {
    // First log ever
    if (current.lastLogDate == null) {
      return StreakModel(
        currentStreak: 1,
        longestStreak: 1,
        lastLogDate: logDate,
      );
    }

    final hoursSinceLastLog = logDate.difference(current.lastLogDate!).inHours;

    // Within 24 hours - continue streak
    if (hoursSinceLastLog <= 24) {
      final newCurrent = current.currentStreak + 1;
      return current.copyWith(
        currentStreak: newCurrent,
        longestStreak: newCurrent > current.longestStreak ? newCurrent : current.longestStreak,
        lastLogDate: logDate,
      );
    }
    
    // Within 48 hours - grace period, maintain streak
    if (hoursSinceLastLog <= 48) {
      return current.copyWith(
        lastLogDate: logDate,
      );
    }

    // Beyond 48 hours - reset streak
    return StreakModel(
      currentStreak: 1,
      longestStreak: current.longestStreak,
      lastLogDate: logDate,
    );
  }
}
