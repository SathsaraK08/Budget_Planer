import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/daily_spend.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';
import 'quick_spend_dialog.dart';

class DailySpendsScreen extends StatelessWidget {
  const DailySpendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final spends = repo.dailySpends;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final totalSpent = repo.currentMetrics.totalDailySpent;
    final totalCash = repo.currentMetrics.totalCashSpent;
    final totalCard = repo.currentMetrics.totalCardSpent;

    // Group spends by formatted date
    final Map<String, List<DailySpend>> groupedSpends = {};
    for (final spend in spends) {
      final key = spend.formattedDate;
      groupedSpends.putIfAbsent(key, () => []).add(spend);
    }

    final sortedDates = groupedSpends.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Spend Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Spend Card
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
                const Text('TOTAL DAILY SPENDS THIS CYCLE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '$symbol ${numFormat.format(totalSpent)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.danger),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Cash: $symbol ${numFormat.format(totalCash)}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Card/Transfer: $symbol ${numFormat.format(totalCard)}', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (spends.isEmpty)
            const Center(child: Text('No spends logged yet. Tap + to add.'))
          else
            ...sortedDates.map((dateStr) {
              final dayItems = groupedSpends[dateStr]!;
              final dayTotal = dayItems.fold(0.0, (sum, i) => sum + i.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                        Text(
                          'Day Total: $symbol ${numFormat.format(dayTotal)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryLight),
                        ),
                      ],
                    ),
                  ),
                  ...dayItems.map((item) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isCash ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                          child: Icon(
                            item.isCash ? Icons.money : Icons.credit_card,
                            color: item.isCash ? Colors.amber : Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${item.category} • ${item.paymentMethod}${item.notes != null && item.notes!.isNotEmpty ? ' (${item.notes})' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '-$symbol ${numFormat.format(item.amount)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.danger),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                              onPressed: () => repo.deleteDailySpend(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const QuickSpendDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
