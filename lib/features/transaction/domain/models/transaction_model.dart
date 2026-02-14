import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? emotion;
  final String? note;
  final bool isIncome;
  final String? timeOfDay; // morning, afternoon, evening, night

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.emotion,
    this.note,
    this.isIncome = false,
    this.timeOfDay,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      note: json['note'],
      isIncome: json['is_income'] == 1,
      timeOfDay: json['time_of_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'note': note,
      'is_income': isIncome ? 1 : 0,
      'time_of_day': timeOfDay,
    };
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    category,
    date,
    emotion,
    note,
    isIncome,
    timeOfDay,
  ];
}
