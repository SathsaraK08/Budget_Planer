import 'package:flutter_test/flutter_test.dart';
import 'package:household_budget_planner/core/engine/budget_engine.dart';
import 'package:household_budget_planner/core/models/income_entry.dart';
import 'package:household_budget_planner/core/models/fixed_payment.dart';
import 'package:household_budget_planner/core/models/installment_plan.dart';
import 'package:household_budget_planner/core/models/credit_card.dart';
import 'package:household_budget_planner/core/models/subscription.dart';
import 'package:household_budget_planner/core/models/wishlist_item.dart';
import 'package:household_budget_planner/core/models/daily_spend.dart';
import 'package:household_budget_planner/core/models/member.dart';
import 'package:household_budget_planner/core/models/forecast_settings.dart';

void main() {
  group('BudgetEngine - 100% Deterministic Financial Calculation Tests', () {
    final now = DateTime(2026, 8, 25);

    // Sample data matching the notebook
    final incomeEntries = [
      IncomeEntry(
        id: 'inc-1',
        householdId: 'h-1',
        cycleId: 'c-1',
        source: 'Husband Salary',
        amount: 249585.00,
        date: DateTime(2026, 8, 24),
      ),
      IncomeEntry(
        id: 'inc-2',
        householdId: 'h-1',
        cycleId: 'c-1',
        source: 'Wife Salary',
        amount: 150000.00,
        date: DateTime(2026, 8, 25),
      ),
    ];

    final fixedPayments = [
      FixedPayment(id: 'f-1', householdId: 'h-1', name: 'Apartment Rent', amount: 70000.0),
      FixedPayment(id: 'f-2', householdId: 'h-1', name: 'Apartment ECB + Water', amount: 20000.0),
      FixedPayment(id: 'f-3', householdId: 'h-1', name: 'Commercial Bank Loan', amount: 47544.0),
      FixedPayment(id: 'f-4', householdId: 'h-1', name: 'Gold Loan Interest', amount: 8500.0),
    ];

    final subscriptions = [
      Subscription(id: 's-1', householdId: 'h-1', name: 'Dialog Mobile', originalAmount: 2054.0, amountLkr: 2054.0),
      Subscription(id: 's-2', householdId: 'h-1', name: 'Dialog Router', originalAmount: 5000.0, amountLkr: 5000.0),
      Subscription(id: 's-3', householdId: 'h-1', name: 'Office Phone Loan', originalAmount: 4500.0, amountLkr: 4500.0),
      Subscription(id: 's-4', householdId: 'h-1', name: 'Netflix Basic', originalAmount: 3.99, amountLkr: 1400.0),
      Subscription(id: 's-5', householdId: 'h-1', name: 'Apple Music', originalAmount: 3.29, amountLkr: 1080.0),
      Subscription(id: 's-6', householdId: 'h-1', name: 'Apple iCloud', originalAmount: 2.99, amountLkr: 1000.0),
    ];

    final creditCards = [
      CreditCard(id: 'cc-1', householdId: 'h-1', bankName: 'Combank', cardName: 'Platinum', statementAmount: 40000.0),
      CreditCard(id: 'cc-2', householdId: 'h-1', bankName: 'Sampath', cardName: 'Signature', statementAmount: 5000.0),
    ];

    final installmentPlans = [
      InstallmentPlan(
        id: 'inst-1',
        householdId: 'h-1',
        platform: 'Koko',
        itemName: 'Water Filter',
        totalAmount: 13647.0,
        monthlyInstallment: 4549.0,
        remainingBalance: 4549.0,
        startDate: now,
      ),
      InstallmentPlan(
        id: 'inst-2',
        householdId: 'h-1',
        platform: 'Koko',
        itemName: 'Perfume',
        totalAmount: 16131.0,
        monthlyInstallment: 5377.0,
        remainingBalance: 10754.0,
        startDate: now,
      ),
      InstallmentPlan(
        id: 'inst-3',
        householdId: 'h-1',
        platform: 'Mintpay',
        itemName: 'Online Grocery',
        totalAmount: 16941.0,
        monthlyInstallment: 5647.0,
        remainingBalance: 5647.0,
        startDate: now,
      ),
    ];

    final dailySpends = [
      DailySpend(id: 'd-1', householdId: 'h-1', cycleId: 'c-1', date: now, amount: 200.0, paymentMethod: 'Cash', title: 'Gym'),
      DailySpend(id: 'd-2', householdId: 'h-1', cycleId: 'c-1', date: now, amount: 6802.0, paymentMethod: 'Commercial Debit Card', title: 'Food City'),
      DailySpend(id: 'd-3', householdId: 'h-1', cycleId: 'c-1', date: now, amount: 406.0, paymentMethod: 'Cash', title: 'PickMe'),
      DailySpend(id: 'd-4', householdId: 'h-1', cycleId: 'c-1', date: now, amount: 4100.0, paymentMethod: 'Card', title: 'Spar Bar'),
    ];

    final wishlistItems = [
      WishlistItem(id: 'w-1', householdId: 'h-1', itemName: 'Potato Smasher', estimatedCost: 800.0, isPlannedForCurrentCycle: true),
      WishlistItem(id: 'w-2', householdId: 'h-1', itemName: 'Air Fryer', estimatedCost: 38000.0, isPlannedForCurrentCycle: false),
    ];

    test('Computes current cycle income and committed outgoings exactly', () {
      final metrics = BudgetEngine.calculateCurrentCycleMetrics(
        incomeEntries: incomeEntries,
        fixedPayments: fixedPayments,
        installmentPlans: installmentPlans,
        creditCards: creditCards,
        subscriptions: subscriptions,
        dailySpends: dailySpends,
        wishlistItems: wishlistItems,
      );

      // Income: 399,585
      expect(metrics.totalIncome, 399585.0);
      // Fixed Bills: 146,044
      expect(metrics.totalFixedBills, 146044.0);
      // Subscriptions: 15,034
      expect(metrics.totalSubscriptions, 15034.0);
      // Credit Cards: 45,000
      expect(metrics.totalCreditCardDues, 45000.0);
      // Installments: 15,573
      expect(metrics.totalInstallmentsDue, 15573.0);
      // Total Committed: 221,651
      expect(metrics.totalCommittedOutgoings, 221651.0);
      // Daily Spent: 11,508
      expect(metrics.totalDailySpent, 11508.0);
      // Remaining Balance: 166,426
      expect(metrics.remainingBalance, 166426.0);
      // Projected Savings: 165,626
      expect(metrics.projectedSavings, 165626.0);
    });

    test('Forecasting Engine with default ForecastSettings calculates surplus', () {
      final members = [
        HouseholdMember(id: 'm-1', householdId: 'h-1', name: 'Husband', regularMonthlySalary: 249585.0),
        HouseholdMember(id: 'm-2', householdId: 'h-1', name: 'Wife', regularMonthlySalary: 150000.0),
      ];

      final forecast = BudgetEngine.calculateNextCycleForecast(
        members: members,
        fixedPayments: fixedPayments,
        installmentPlans: installmentPlans,
        subscriptions: subscriptions,
        settings: const ForecastSettings(reservePercentage: 5.0),
        estimatedNextCreditCardDues: 10000.0,
      );

      expect(forecast.estimatedIncome, 399585.0);
      expect(forecast.recurringFixedBills, 146044.0);
      expect(forecast.recurringSubscriptions, 15034.0);
      expect(forecast.completedInstallmentsCount, 2);
      expect(forecast.continuingInstallmentsCount, 1);
      expect(forecast.continuingInstallments, 5377.0);
      expect(forecast.totalEstimatedCommitted, 176455.0);
      expect(forecast.projectedNetBalance, 223130.0);
      expect(forecast.hasShortfall, false);
      expect(forecast.requiredSurvivalBuffer, 0.0);
    });

    test('Forecasting Engine flags shortfall and scales reserve buffer with custom reserve percentage', () {
      final members = [
        HouseholdMember(id: 'm-1', householdId: 'h-1', name: 'Husband', regularMonthlySalary: 100000.0),
        HouseholdMember(id: 'm-2', householdId: 'h-1', name: 'Wife', regularMonthlySalary: 0.0),
      ];

      // Test with 10% reserve margin
      final forecast = BudgetEngine.calculateNextCycleForecast(
        members: members,
        fixedPayments: fixedPayments,
        installmentPlans: installmentPlans,
        subscriptions: subscriptions,
        settings: const ForecastSettings(reservePercentage: 10.0),
        estimatedNextCreditCardDues: 10000.0,
      );

      expect(forecast.hasShortfall, true);
      expect(forecast.shortfallAmount, 76455.0);
      // Required buffer = 76,455 + (100,000 * 0.10) = 76,455 + 10,000 = 86,455
      expect(forecast.requiredSurvivalBuffer, 86455.0);
    });
  });
}
