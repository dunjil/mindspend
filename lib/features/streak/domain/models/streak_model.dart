
import 'package:equatable/equatable.dart';

class StreakModel extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLogDate;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastLogDate,
  });

  factory StreakModel.initial() {
    return const StreakModel(
      currentStreak: 0,
      longestStreak: 0,
      lastLogDate: null,
    );
  }

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastLogDate: json['lastLogDate'] != null 
          ? DateTime.parse(json['lastLogDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLogDate': lastLogDate?.toIso8601String(),
    };
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLogDate,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
    );
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastLogDate];
}
