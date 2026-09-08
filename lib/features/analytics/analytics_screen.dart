import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

/// Analytics screen — income vs. outgoings line chart, category breakdown,
/// BNPL payoff progress bars, savings rate trend.
/// All reads from real data via BudgetRepository. Matches spec §10.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final metrics = repo.currentMetrics;
    final symbol = repo.household.currencySymbol;
    final fmt = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current Cycle Summary ──────────────────────────────────────
            _sectionHeader('CURRENT CYCLE SUMMARY'),
            const SizedBox(height: 12),

            _buildIncomeVsOutgoingsBar(metrics, symbol, fmt),
            const SizedBox(height: 24),

            // ── Category Breakdown ────────────────────────────────────────
            _sectionHeader('SPEND BY CATEGORY (THIS CYCLE)'),
            const SizedBox(height: 12),

            _buildCategoryBreakdown(repo, symbol, fmt),
            const SizedBox(height: 24),

            // ── BNPL Payoff Progress ─────────────────────────────────────
            _sectionHeader('BNPL INSTALLMENT PROGRESS'),
            const SizedBox(height: 12),

            _buildBnplProgress(repo, symbol, fmt),
            const SizedBox(height: 24),

            // ── Savings Rate ────────────────────────────────────────────
            _sectionHeader('CYCLE SAVINGS RATE'),
            const SizedBox(height: 12),

            _buildSavingsRateCard(metrics, symbol, fmt),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildIncomeVsOutgoingsBar(dynamic metrics, String symbol, NumberFormat fmt) {
    final totalIncome = metrics.totalIncome as double;
    final committed = metrics.totalCommittedOutgoings as double;
    final spent = metrics.totalDailySpent as double;
    final remaining = metrics.remainingBalance as double;

    if (totalIncome == 0) {
      return _emptyState('No income recorded for this cycle yet.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          _buildBar('Income', totalIncome, totalIncome, AppTheme.primary, symbol, fmt),
          const SizedBox(height: 10),
          _buildBar('Committed Bills', committed, totalIncome, AppTheme.warning, symbol, fmt),
          const SizedBox(height: 10),
          _buildBar('Daily Spent', spent, totalIncome, AppTheme.info, symbol, fmt),
          const SizedBox(height: 10),
          _buildBar(
            remaining >= 0 ? 'Remaining' : 'Over Budget',
            remaining.abs(),
            totalIncome,
            remaining >= 0 ? AppTheme.primary : AppTheme.danger,
            symbol,
            fmt,
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double max, Color color, String symbol, NumberFormat fmt) {
    final ratio = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            Text(
              '$symbol ${fmt.format(value)}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppTheme.surfaceElevated,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BudgetRepository repo, String symbol, NumberFormat fmt) {
    // Aggregate daily spends by category
    final Map<String, double> byCategory = {};
    for (final spend in repo.dailySpends) {
      byCategory[spend.category] = (byCategory[spend.category] ?? 0) + spend.amount;
    }

    if (byCategory.isEmpty) {
      return _emptyState('No daily spends logged yet.');
    }

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent = entries.fold(0.0, (s, e) => s + e.value);

    final colors = [
      AppTheme.primary, AppTheme.secondary, AppTheme.warning,
      AppTheme.info, AppTheme.accent, AppTheme.danger,
      AppTheme.primaryLight,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final color = colors[e.key % colors.length];
          final category = e.value.key;
          final amount = e.value.value;
          final pct = totalSpent > 0 ? (amount / totalSpent * 100) : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(category, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                    Text(
                      '$symbol ${fmt.format(amount)} (${pct.toStringAsFixed(1)}%)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalSpent > 0 ? (amount / totalSpent).clamp(0.0, 1.0) : 0,
                    backgroundColor: AppTheme.surfaceElevated,
                    color: color,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBnplProgress(BudgetRepository repo, String symbol, NumberFormat fmt) {
    final active = repo.installmentPlans.where((p) => p.isActive).toList();
    if (active.isEmpty) {
      return _emptyState('No active BNPL installment plans.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: active.map((plan) {
          final paidAmt = plan.totalAmount - plan.remainingBalance;
          final progress = plan.totalAmount > 0
              ? (paidAmt / plan.totalAmount).clamp(0.0, 1.0)
              : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.itemName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${plan.installmentsPaid}/${plan.totalInstallments}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        plan.platform,
                        style: const TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remaining: $symbol ${fmt.format(plan.remainingBalance)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceElevated,
                    color: progress >= 1.0 ? AppTheme.primary : AppTheme.warning,
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavingsRateCard(dynamic metrics, String symbol, NumberFormat fmt) {
    final income = metrics.totalIncome as double;
    final savings = metrics.projectedSavings as double;
    final rate = income > 0 ? (savings / income * 100) : 0.0;
    final isPositive = savings >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [const Color(0xFF450A0A), const Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPositive ? AppTheme.primary.withOpacity(0.3) : AppTheme.danger.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECTED SAVINGS RATE (THIS CYCLE)',
            style: TextStyle(fontSize: 11, letterSpacing: 1.0, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppTheme.primaryLight : AppTheme.danger,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPositive
                ? 'Projected savings: $symbol ${fmt.format(savings)}'
                : 'Over budget by: $symbol ${fmt.format(savings.abs())}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
