class Subscription {
  final String id;
  final String householdId;
  final String name; // 'Netflix Basic', 'Apple Music', 'Dialog Router'
  final String originalCurrency; // 'USD', 'LKR'
  final double originalAmount;
  final double amountLkr;
  final int billingDay;
  final String category; // 'Telecom', 'Entertainment', 'Cloud', 'Work'
  final bool isActive;
  final bool isPaid; // For active cycle
  final String? paidDate;

  Subscription({
    required this.id,
    required this.householdId,
    required this.name,
    this.originalCurrency = 'LKR',
    required this.originalAmount,
    required this.amountLkr,
    this.billingDay = 24,
    this.category = 'Entertainment',
    this.isActive = true,
    this.isPaid = false,
    this.paidDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json, {bool isPaid = false, String? paidDate}) {
    return Subscription(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      name: json['name'] as String? ?? 'Subscription',
      originalCurrency: json['original_currency'] as String? ?? 'LKR',
      originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0.0,
      amountLkr: (json['amount_lkr'] as num?)?.toDouble() ?? 0.0,
      billingDay: (json['billing_day'] as num?)?.toInt() ?? 24,
      category: json['category'] as String? ?? 'Entertainment',
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
      'original_currency': originalCurrency,
      'original_amount': originalAmount,
      'amount_lkr': amountLkr,
      'billing_day': billingDay,
      'category': category,
      'is_active': isActive,
    };
  }

  Subscription copyWith({
    String? id,
    String? householdId,
    String? name,
    String? originalCurrency,
    double? originalAmount,
    double? amountLkr,
    int? billingDay,
    String? category,
    bool? isActive,
    bool? isPaid,
    String? paidDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmount: originalAmount ?? this.originalAmount,
      amountLkr: amountLkr ?? this.amountLkr,
      billingDay: billingDay ?? this.billingDay,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
    );
  }
}
