class FixedPayment {
  final String id;
  final String householdId;
  final String name; // 'Apartment Rent', 'ECB + Water', 'Commercial Bank Loan'
  final double amount;
  final int dueDayOfMonth;
  final String category; // 'Housing', 'Utilities', 'Loan', 'Insurance'
  final String? transferDestination; // 'BOC Account'
  final bool isRecurring;
  final bool isActive;
  final bool isPaid; // For active cycle
  final String? paidDate;

  FixedPayment({
    required this.id,
    required this.householdId,
    required this.name,
    required this.amount,
    this.dueDayOfMonth = 25,
    this.category = 'Housing',
    this.transferDestination,
    this.isRecurring = true,
    this.isActive = true,
    this.isPaid = false,
    this.paidDate,
  });

  factory FixedPayment.fromJson(Map<String, dynamic> json, {bool isPaid = false, String? paidDate}) {
    return FixedPayment(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String? ?? 'Bill',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDayOfMonth: (json['due_day_of_month'] as num?)?.toInt() ?? 25,
      category: json['category'] as String? ?? 'Housing',
      transferDestination: json['transfer_destination'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      isPaid: json['is_paid'] as bool? ?? isPaid,
      paidDate: json['paid_date'] as String? ?? paidDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'name': name,
      'amount': amount,
      'due_day_of_month': dueDayOfMonth,
      'category': category,
      if (transferDestination != null) 'transfer_destination': transferDestination,
      'is_recurring': isRecurring,
      'is_active': isActive,
    };
  }

  FixedPayment copyWith({
    String? id,
    String? householdId,
    String? name,
    double? amount,
    int? dueDayOfMonth,
    String? category,
    String? transferDestination,
    bool? isRecurring,
    bool? isActive,
    bool? isPaid,
    String? paidDate,
  }) {
    return FixedPayment(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      category: category ?? this.category,
      transferDestination: transferDestination ?? this.transferDestination,
      isRecurring: isRecurring ?? this.isRecurring,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
    );
  }
}
