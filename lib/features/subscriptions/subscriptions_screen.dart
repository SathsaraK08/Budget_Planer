import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final subs = repo.subscriptions;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final total = repo.currentMetrics.totalSubscriptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions & Auto-Pay'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MONTHLY SUBSCRIPTIONS TOTAL', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol ${numFormat.format(total)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.info),
                    ),
                  ],
                ),
                const Icon(Icons.subscriptions_outlined, size: 36, color: AppTheme.info),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('RECURRING SERVICES (AUTO-CONVERTED TO LKR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),

          ...subs.map((s) {
            final isUsd = s.originalCurrency == 'USD';

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.info.withOpacity(0.2),
                  child: Icon(
                    s.category == 'Telecom' ? Icons.wifi : Icons.play_circle_outline,
                    color: AppTheme.info,
                    size: 20,
                  ),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Billing: ${s.billingDay}th of month • ${s.category}${isUsd ? ' (\$${s.originalAmount})' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$symbol ${numFormat.format(s.amountLkr)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: s.isPaid ? AppTheme.primaryLight : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        s.isPaid ? Icons.check_circle : Icons.circle_outlined,
                        color: s.isPaid ? AppTheme.primaryLight : AppTheme.textMuted,
                      ),
                      onPressed: () => repo.toggleSubscriptionPaid(s.id),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
