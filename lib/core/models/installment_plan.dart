import 'package:intl/intl.dart';

class InstallmentPlan {
  final String id;
  final String householdId;
  final String? memberId;
  final String platform; // 'Koko', 'Mintpay', 'PayZy', 'Commercial Bank'
  final String itemName;
  final String? vendor;
  final double totalAmount;
  final double monthlyInstallment;
  final double remainingBalance;
  final int totalInstallments;
  final int installmentsPaid;
  final int dueDayOfMonth;
  final DateTime startDate;
  final DateTime? expectedEndDate;
  final String status; // 'active', 'completed', 'cancelled'
  final bool isPaidInCurrentCycle;

  InstallmentPlan({
    required this.id,
    required this.householdId,
    this.memberId,
    this.platform = 'Koko',
    required this.itemName,
    this.vendor,
    required this.totalAmount,
    required this.monthlyInstallment,
    required this.remainingBalance,
    this.totalInstallments = 3,
    this.installmentsPaid = 0,
    this.dueDayOfMonth = 26,
    required this.startDate,
    this.expectedEndDate,
    this.status = 'active',
    this.isPaidInCurrentCycle = false,
  });

  bool get isActive => status == 'active' && remainingBalance > 0;
  bool get isCompleted => status == 'completed' || remainingBalance <= 0;

  double get progressPercentage {
    if (totalAmount <= 0) return 1.0;
    final paidAmount = totalAmount - remainingBalance;
    return (paidAmount / totalAmount).clamp(0.0, 1.0);
  }

  // Will this installment still have a balance due in the NEXT cycle?
  bool get continuesToNextCycle {
    if (!isActive) return false;
    final balanceAfterCurrentCycle = remainingBalance - monthlyInstallment;
    return balanceAfterCurrentCycle > 0.01;
  }

  double get nextCycleDueAmount {
    if (!continuesToNextCycle) return 0.0;
    final balanceAfterCurrentCycle = remainingBalance - monthlyInstallment;
    return balanceAfterCurrentCycle < monthlyInstallment ? balanceAfterCurrentCycle : monthlyInstallment;
  }

  factory InstallmentPlan.fromJson(Map<String, dynamic> json, {bool isPaidInCurrentCycle = false}) {
    return InstallmentPlan(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      memberId: json['member_id'] as String?,
      platform: json['platform'] as String? ?? 'Koko',
      itemName: json['item_name'] as String? ?? 'Item',
      vendor: json['vendor'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment: (json['monthly_installment'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble() ?? 0.0,
      totalInstallments: (json['total_installments'] as num?)?.toInt() ?? 3,
      installmentsPaid: (json['installments_paid'] as num?)?.toInt() ?? 0,
      dueDayOfMonth: (json['due_day_of_month'] as num?)?.toInt() ?? 26,
      startDate: DateTime.parse(json['start_date'] as String),
      expectedEndDate: json['expected_end_date'] != null ? DateTime.parse(json['expected_end_date'] as String) : null,
      status: json['status'] as String? ?? 'active',
      isPaidInCurrentCycle: json['is_paid_in_current_cycle'] as bool? ?? isPaidInCurrentCycle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'member_id': memberId,
      'platform': platform,
      'item_name': itemName,
      if (vendor != null) 'vendor': vendor,
      'total_amount': totalAmount,
      'monthly_installment': monthlyInstallment,
      'remaining_balance': remainingBalance,
      'total_installments': totalInstallments,
      'installments_paid': installmentsPaid,
      'due_day_of_month': dueDayOfMonth,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      if (expectedEndDate != null) 'expected_end_date': DateFormat('yyyy-MM-dd').format(expectedEndDate!),
      'status': status,
    };
  }

  InstallmentPlan copyWith({
    String? id,
    String? householdId,
    String? memberId,
    String? platform,
    String? itemName,
    String? vendor,
    double? totalAmount,
    double? monthlyInstallment,
    double? remainingBalance,
    int? totalInstallments,
    int? installmentsPaid,
    int? dueDayOfMonth,
    DateTime? startDate,
    DateTime? expectedEndDate,
    String? status,
    bool? isPaidInCurrentCycle,
  }) {
    return InstallmentPlan(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      memberId: memberId ?? this.memberId,
      platform: platform ?? this.platform,
      itemName: itemName ?? this.itemName,
      vendor: vendor ?? this.vendor,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      installmentsPaid: installmentsPaid ?? this.installmentsPaid,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      status: status ?? this.status,
      isPaidInCurrentCycle: isPaidInCurrentCycle ?? this.isPaidInCurrentCycle,
    );
  }
}
