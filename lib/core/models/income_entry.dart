import 'package:intl/intl.dart';

class IncomeEntry {
  final String id;
  final String householdId;
  final String cycleId;
  final String? memberId;
  final String source; // 'Salary', 'Bonus', 'Freelance', 'Other'
  final double amount;
  final DateTime date;
  final String? notes;

  IncomeEntry({
    required this.id,
    required this.householdId,
    required this.cycleId,
    this.memberId,
    required this.source,
    required this.amount,
    required this.date,
    this.notes,
  });

  factory IncomeEntry.fromJson(Map<String, dynamic> json) {
    return IncomeEntry(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      cycleId: json['cycle_id'] as String,
      memberId: json['member_id'] as String?,
      source: json['source'] as String? ?? 'Income',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'cycle_id': cycleId,
      'member_id': memberId,
      'source': source,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      if (notes != null) 'notes': notes,
    };
  }

  IncomeEntry copyWith({
    String? id,
    String? householdId,
    String? cycleId,
    String? memberId,
    String? source,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      cycleId: cycleId ?? this.cycleId,
      memberId: memberId ?? this.memberId,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
