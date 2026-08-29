class CreditCard {
  final String id;
  final String householdId;
  final String? memberId;
  final String bankName; // 'Commercial Bank', 'Sampath Bank', 'DFCC'
  final String cardName; // 'Combank Platinum'
  final double creditLimit;
  final int statementDay;
  final int dueDay;
  final bool isActive;
  final double statementAmount; // For active cycle
  final double minimumDue;
  final bool isPaid; // For active cycle
  final double paidAmount;
  final String? paidDate;

  CreditCard({
    required this.id,
    required this.householdId,
    this.memberId,
    required this.bankName,
    required this.cardName,
    this.creditLimit = 0.0,
    this.statementDay = 10,
    this.dueDay = 26,
    this.isActive = true,
    this.statementAmount = 0.0,
    this.minimumDue = 0.0,
    this.isPaid = false,
    this.paidAmount = 0.0,
    this.paidDate,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json, {
    double statementAmount = 0.0,
    double minimumDue = 0.0,
    bool isPaid = false,
    double paidAmount = 0.0,
    String? paidDate,
  }) {
    return CreditCard(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      memberId: json['member_id'] as String?,
      bankName: json['bank_name'] as String? ?? 'Bank',
      cardName: json['card_name'] as String? ?? 'Credit Card',
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      statementDay: (json['statement_day'] as num?)?.toInt() ?? 10,
      dueDay: (json['due_day'] as num?)?.toInt() ?? 26,
      isActive: json['is_active'] as bool? ?? true,
      statementAmount: (json['statement_amount'] as num?)?.toDouble() ?? statementAmount,
      minimumDue: (json['minimum_due'] as num?)?.toDouble() ?? minimumDue,
      isPaid: json['is_paid'] as bool? ?? isPaid,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? paidAmount,
      paidDate: json['paid_date'] as String? ?? paidDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'member_id': memberId,
      'bank_name': bankName,
      'card_name': cardName,
      'credit_limit': creditLimit,
      'statement_day': statementDay,
      'due_day': dueDay,
      'is_active': isActive,
    };
  }

  CreditCard copyWith({
    String? id,
    String? householdId,
    String? memberId,
    String? bankName,
    String? cardName,
    double? creditLimit,
    int? statementDay,
    int? dueDay,
    bool? isActive,
    double? statementAmount,
    double? minimumDue,
    bool? isPaid,
    double? paidAmount,
    String? paidDate,
  }) {
    return CreditCard(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      memberId: memberId ?? this.memberId,
      bankName: bankName ?? this.bankName,
      cardName: cardName ?? this.cardName,
      creditLimit: creditLimit ?? this.creditLimit,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      statementAmount: statementAmount ?? this.statementAmount,
      minimumDue: minimumDue ?? this.minimumDue,
      isPaid: isPaid ?? this.isPaid,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
    );
  }
}
