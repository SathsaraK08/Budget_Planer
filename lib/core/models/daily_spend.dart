import 'package:intl/intl.dart';

class DailySpend {
  final String id;
  final String householdId;
  final String cycleId;
  final String? memberId;
  final DateTime date;
  final double amount;
  final String category;
  final String paymentMethod; // 'Cash', 'Commercial Debit Card', 'Sampath Card', 'Fund Transfer'
  final String title;
  final String? notes;

  DailySpend({
    required this.id,
    required this.householdId,
    required this.cycleId,
    this.memberId,
    required this.date,
    required this.amount,
    this.category = 'Groceries',
    this.paymentMethod = 'Cash',
    required this.title,
    this.notes,
  });

  bool get isCash => paymentMethod.toLowerCase().contains('cash');
  bool get isCard => paymentMethod.toLowerCase().contains('card');
  bool get isTransfer => paymentMethod.toLowerCase().contains('transfer');

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  factory DailySpend.fromJson(Map<String, dynamic> json) {
    return DailySpend(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      cycleId: json['cycle_id'] as String,
      memberId: json['member_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Groceries',
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      title: json['title'] as String? ?? 'Expense',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'cycle_id': cycleId,
      'member_id': memberId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'amount': amount,
      'category': category,
      'payment_method': paymentMethod,
      'title': title,
      if (notes != null) 'notes': notes,
    };
  }

  DailySpend copyWith({
    String? id,
    String? householdId,
    String? cycleId,
    String? memberId,
    DateTime? date,
    double? amount,
    String? category,
    String? paymentMethod,
    String? title,
    String? notes,
  }) {
    return DailySpend(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      cycleId: cycleId ?? this.cycleId,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }
}
