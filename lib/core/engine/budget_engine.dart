import '../models/income_entry.dart';
import '../models/fixed_payment.dart';
import '../models/installment_plan.dart';
import '../models/credit_card.dart';
import '../models/subscription.dart';
import '../models/wishlist_item.dart';
import '../models/daily_spend.dart';
import '../models/member.dart';
import '../models/forecast_result.dart';
import '../models/forecast_settings.dart';

class BudgetEngine {
  /// Pure deterministic calculation of current cycle financial health.
  /// Verified against notebook formulas.
  static CurrentCycleMetrics calculateCurrentCycleMetrics({
    required List<IncomeEntry> incomeEntries,
    required List<FixedPayment> fixedPayments,
    required List<InstallmentPlan> installmentPlans,
    required List<CreditCard> creditCards,
    required List<Subscription> subscriptions,
    required List<DailySpend> dailySpends,
    required List<WishlistItem> wishlistItems,
  }) {
    // 1. Total Income
    final double totalIncome = incomeEntries.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    // 2. Committed Outgoings
    final double totalFixedBills = fixedPayments
        .where((f) => f.isActive)
        .fold(0.0, (sum, item) => sum + item.amount);

    final double totalInstallmentsDue = installmentPlans
        .where((p) => p.isActive)
        .fold(0.0, (sum, item) => sum + item.monthlyInstallment);

    final double totalCreditCardDues = creditCards
        .where((c) => c.isActive)
        .fold(0.0, (sum, item) => sum + item.statementAmount);

    final double totalSubscriptions = subscriptions
        .where((s) => s.isActive)
        .fold(0.0, (sum, item) => sum + item.amountLkr);

    final double totalCommittedOutgoings =
        totalFixedBills + totalInstallmentsDue + totalCreditCardDues + totalSubscriptions;

    // 3. Daily Spends
    double totalCashSpent = 0.0;
    double totalCardSpent = 0.0;

    for (final spend in dailySpends) {
      if (spend.isCash) {
        totalCashSpent += spend.amount;
      } else {
        totalCardSpent += spend.amount;
      }
    }
    final double totalDailySpent = totalCashSpent + totalCardSpent;

    // 4. Planned Wishlist
    final double totalPlannedWishlist = wishlistItems
        .where((w) => !w.isPurchased && w.isPlannedForCurrentCycle)
        .fold(0.0, (sum, item) => sum + item.estimatedCost);

    // 5. Remaining Balance & Projected Savings
    final double remainingBalance = totalIncome - (totalCommittedOutgoings + totalDailySpent);
    final double projectedSavings = remainingBalance - totalPlannedWishlist;

    // 6. Ratios
    final double committedRatio = totalIncome > 0 ? (totalCommittedOutgoings / totalIncome).clamp(0.0, 1.0) : 0.0;
    final double spentRatio = totalIncome > 0 ? (totalDailySpent / totalIncome).clamp(0.0, 1.0) : 0.0;
    final double remainingRatio = totalIncome > 0 ? (remainingBalance / totalIncome).clamp(0.0, 1.0) : 0.0;

    return CurrentCycleMetrics(
      totalIncome: totalIncome,
      totalFixedBills: totalFixedBills,
      totalInstallmentsDue: totalInstallmentsDue,
      totalCreditCardDues: totalCreditCardDues,
      totalSubscriptions: totalSubscriptions,
      totalCommittedOutgoings: totalCommittedOutgoings,
      totalDailySpent: totalDailySpent,
      totalCashSpent: totalCashSpent,
      totalCardSpent: totalCardSpent,
      totalPlannedWishlist: totalPlannedWishlist,
      remainingBalance: remainingBalance,
      projectedSavings: projectedSavings,
      committedRatio: committedRatio,
      spentRatio: spentRatio,
      remainingRatio: remainingRatio,
    );
  }

  /// Forward-Looking Survivability Check for the upcoming cycle.
  /// Analyzes recurring obligations and installment lifecycles with tunable parameters.
  static NextCycleForecast calculateNextCycleForecast({
    required List<HouseholdMember> members,
    required List<FixedPayment> fixedPayments,
    required List<InstallmentPlan> installmentPlans,
    required List<Subscription> subscriptions,
    ForecastSettings settings = const ForecastSettings(),
    double? customEstimatedNextIncome,
    double estimatedNextCreditCardDues = 0.0,
  }) {
    // 1. Estimated Income
    final double estimatedIncome = customEstimatedNextIncome ??
        members.fold(0.0, (sum, m) => sum + m.regularMonthlySalary);

    // 2. Next Cycle Fixed Bills (Recurring only)
    final double recurringFixedBills = fixedPayments
        .where((f) => f.isActive && f.isRecurring)
        .fold(0.0, (sum, item) => sum + item.amount);

    // 3. Installment Lifecycle Tracking
    int completedInstallmentsCount = 0;
    int continuingInstallmentsCount = 0;
    double continuingInstallments = 0.0;
    final List<String> highCommitmentFactors = [];

    for (final plan in installmentPlans) {
      if (!plan.isActive) continue;

      if (plan.continuesToNextCycle) {
        continuingInstallmentsCount++;
        final nextDue = plan.nextCycleDueAmount;
        continuingInstallments += nextDue;
        if (nextDue >= 3000) {
          highCommitmentFactors.add('${plan.platform}: ${plan.itemName} (Rs. ${nextDue.toStringAsFixed(0)})');
        }
      } else {
        completedInstallmentsCount++;
      }
    }

    // 4. Subscriptions
    final double recurringSubscriptions = subscriptions
        .where((s) => s.isActive)
        .fold(0.0, (sum, item) => sum + item.amountLkr);

    // Add largest fixed bills to high commitment list
    final sortedBills = List<FixedPayment>.from(fixedPayments.where((f) => f.isActive))
      ..sort((a, b) => b.amount.compareTo(a.amount));
    for (final bill in sortedBills.take(3)) {
      highCommitmentFactors.insert(0, '${bill.name} (Rs. ${bill.amount.toStringAsFixed(0)})');
    }

    // 5. Total Estimated Committed
    final double totalEstimatedCommitted = recurringFixedBills +
        continuingInstallments +
        recurringSubscriptions +
        estimatedNextCreditCardDues;

    // 6. Net Projected Balance & Shortfall Detection
    final double projectedNetBalance = estimatedIncome - totalEstimatedCommitted;
    final bool hasShortfall = projectedNetBalance < 0;
    final double shortfallAmount = hasShortfall ? projectedNetBalance.abs() : 0.0;

    // 7. Required Minimum Survival Buffer (Calculated with tunable reserve percentage)
    final double reserveMargin = (settings.reservePercentage / 100.0) * estimatedIncome;
    final double requiredSurvivalBuffer = hasShortfall
        ? (shortfallAmount + reserveMargin)
        : 0.0;

    return NextCycleForecast(
      estimatedIncome: estimatedIncome,
      recurringFixedBills: recurringFixedBills,
      continuingInstallments: continuingInstallments,
      recurringSubscriptions: recurringSubscriptions,
      estimatedCreditCardDues: estimatedNextCreditCardDues,
      totalEstimatedCommitted: totalEstimatedCommitted,
      projectedNetBalance: projectedNetBalance,
      hasShortfall: hasShortfall,
      shortfallAmount: shortfallAmount,
      requiredSurvivalBuffer: requiredSurvivalBuffer,
      completedInstallmentsCount: completedInstallmentsCount,
      continuingInstallmentsCount: continuingInstallmentsCount,
      highCommitmentFactors: highCommitmentFactors,
    );
  }
}
