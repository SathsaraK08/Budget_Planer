import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final currentMetrics = repo.currentMetrics;
    final forecast = repo.nextForecast;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');

    final isShortfall = forecast.hasShortfall;
    final netBalance = forecast.projectedNetBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Survival Forecast'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Critical Survival Verdict Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isShortfall
                      ? [const Color(0xFF7F1D1D), const Color(0xFF1E1B4B)]
                      : [const Color(0xFF065F46), const Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isShortfall ? AppTheme.danger : AppTheme.primaryLight,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isShortfall ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
                        color: isShortfall ? AppTheme.warning : AppTheme.primaryLight,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isShortfall ? 'NEXT CYCLE SHORTFALL ALERT' : 'NEXT CYCLE SAFE & HEALTHY',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isShortfall ? 'Projected Deficit:' : 'Projected Net Surplus:',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  Text(
                    '$symbol ${numFormat.format(netBalance.abs())}',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: isShortfall ? AppTheme.danger : AppTheme.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  if (isShortfall) ...[
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                              children: [
                                const TextSpan(text: 'Mandatory Action: Reserve '),
                                TextSpan(
                                  text: '$symbol ${numFormat.format(forecast.requiredSurvivalBuffer)} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warning),
                                ),
                                const TextSpan(text: 'from this month\'s balance to avoid debt.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_outlined, color: AppTheme.primaryLight, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your next month regular salaries comfortably cover all recurring commitments and active installments.',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Next Cycle Breakdown Table
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXT CYCLE COMMITTED COST PROJECTION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  _buildForecastRow('Estimated Next Month Income', forecast.estimatedIncome, symbol, numFormat, isIncome: true),
                  const Divider(),
                  _buildForecastRow('Recurring Fixed Bills (Rent, Utilities, Bank Loan)', forecast.recurringFixedBills, symbol, numFormat),
                  _buildForecastRow('Continuing BNPL Installments', forecast.continuingInstallments, symbol, numFormat),
                  _buildForecastRow('Active Subscriptions (Dialog, Netflix, Apple)', forecast.recurringSubscriptions, symbol, numFormat),
                  _buildForecastRow('Estimated Credit Card Base', forecast.estimatedCreditCardDues, symbol, numFormat),
                  const Divider(),
                  _buildForecastRow('Total Next Cycle Committed Costs', forecast.totalEstimatedCommitted, symbol, numFormat, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Installment Lifecycle Status
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INSTALLMENTS LIFECYCLE TRACKER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${forecast.completedInstallmentsCount}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                              ),
                              const Text('Ending This Month', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              const Text('Releases Cash Flow', style: TextStyle(fontSize: 10, color: AppTheme.primaryLight)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${forecast.continuingInstallmentsCount}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.warning),
                              ),
                              const Text('Continuing Next Month', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              Text('$symbol ${numFormat.format(forecast.continuingInstallments)} Due', style: const TextStyle(fontSize: 10, color: AppTheme.warning)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Current vs Required Reserve Comparison
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SURVIVAL BUFFER EVALUATION',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Realtime Balance:', style: TextStyle(color: AppTheme.textSecondary)),
                      Text(
                        '$symbol ${numFormat.format(currentMetrics.remainingBalance)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Survival Reserve Needed:', style: TextStyle(color: AppTheme.textSecondary)),
                      Text(
                        '$symbol ${numFormat.format(forecast.requiredSurvivalBuffer)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: forecast.requiredSurvivalBuffer > 0 ? AppTheme.warning : AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Safe Discretionary Spendable Funds:', style: TextStyle(color: AppTheme.textSecondary)),
                      Text(
                        '$symbol ${numFormat.format(currentMetrics.remainingBalance - forecast.requiredSurvivalBuffer)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(
    String label,
    double amount,
    String symbol,
    NumberFormat fmt, {
    bool isIncome = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}$symbol ${fmt.format(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: FontWeight.bold,
              color: isIncome
                  ? AppTheme.primaryLight
                  : (isTotal ? AppTheme.danger : AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
