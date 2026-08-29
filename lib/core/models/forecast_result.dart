class CurrentCycleMetrics {
  final double totalIncome;
  final double totalFixedBills;
  final double totalInstallmentsDue;
  final double totalCreditCardDues;
  final double totalSubscriptions;
  final double totalCommittedOutgoings;
  
  final double totalDailySpent;
  final double totalCashSpent;
  final double totalCardSpent;
  
  final double totalPlannedWishlist;
  
  // Realtime balance: Total Income - (Committed Outgoings + Daily Spent)
  final double remainingBalance;
  
  // Projected End-of-Cycle Savings: Remaining Balance - Planned Wishlist
  final double projectedSavings;
  
  // Progress ratios
  final double committedRatio;
  final double spentRatio;
  final double remainingRatio;

  CurrentCycleMetrics({
    required this.totalIncome,
    required this.totalFixedBills,
    required this.totalInstallmentsDue,
    required this.totalCreditCardDues,
    required this.totalSubscriptions,
    required this.totalCommittedOutgoings,
    required this.totalDailySpent,
    required this.totalCashSpent,
    required this.totalCardSpent,
    required this.totalPlannedWishlist,
    required this.remainingBalance,
    required this.projectedSavings,
    required this.committedRatio,
    required this.spentRatio,
    required this.remainingRatio,
  });
}

class NextCycleForecast {
  final double estimatedIncome;
  final double recurringFixedBills;
  final double continuingInstallments;
  final double recurringSubscriptions;
  final double estimatedCreditCardDues;
  final double totalEstimatedCommitted;
  
  // Forward-Looking Survivability Check
  // Surplus if > 0, Shortfall if < 0
  final double projectedNetBalance;
  final bool hasShortfall;
  final double shortfallAmount;
  
  // Buffer needed from current cycle savings to survive next cycle smoothly
  final double requiredSurvivalBuffer;
  
  // Items ending vs continuing
  final int completedInstallmentsCount;
  final int continuingInstallmentsCount;
  final List<String> highCommitmentFactors;

  NextCycleForecast({
    required this.estimatedIncome,
    required this.recurringFixedBills,
    required this.continuingInstallments,
    required this.recurringSubscriptions,
    required this.estimatedCreditCardDues,
    required this.totalEstimatedCommitted,
    required this.projectedNetBalance,
    required this.hasShortfall,
    required this.shortfallAmount,
    required this.requiredSurvivalBuffer,
    required this.completedInstallmentsCount,
    required this.continuingInstallmentsCount,
    required this.highCommitmentFactors,
  });
}
