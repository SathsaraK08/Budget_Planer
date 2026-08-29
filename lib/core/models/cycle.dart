import 'package:intl/intl.dart';

class BudgetCycle {
  final String id;
  final String householdId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'open', 'closed'
  final String? notes;

  BudgetCycle({
    required this.id,
    required this.householdId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.status = 'open',
    this.notes,
  });

  bool get isOpen => status == 'open';

  int get totalDays => endDate.difference(startDate).inDays + 1;

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    if (now.isBefore(startDate)) return totalDays;
    return endDate.difference(DateTime(now.year, now.month, now.day)).inDays + 1;
  }

  double get progressPercentage {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 1.0;
    if (now.isBefore(startDate)) return 0.0;
    final elapsed = now.difference(startDate).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  String get formattedRange {
    final fmt = DateFormat('MMM d');
    return '${fmt.format(startDate)} – ${fmt.format(endDate)}';
  }

  factory BudgetCycle.fromJson(Map<String, dynamic> json) {
    return BudgetCycle(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String? ?? 'Budget Cycle',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'open',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'name': name,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  BudgetCycle copyWith({
    String? id,
    String? householdId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? notes,
  }) {
    return BudgetCycle(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
