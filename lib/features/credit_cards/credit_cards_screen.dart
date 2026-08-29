import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class CreditCardsScreen extends StatelessWidget {
  const CreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final cards = repo.creditCards;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final totalDues = repo.currentMetrics.totalCreditCardDues;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
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
                    const Text('TOTAL CREDIT CARD STATEMENTS DUE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol ${numFormat.format(totalDues)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                    ),
                  ],
                ),
                const Icon(Icons.credit_card, size: 36, color: AppTheme.secondary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('BANK CARDS (TAP TO TOGGLE PAID)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),

          ...cards.map((c) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondary.withOpacity(0.2),
                  child: const Icon(Icons.credit_card, color: AppTheme.secondary, size: 20),
                ),
                title: Text(c.cardName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${c.bankName} • Due: ${c.dueDay}th of month'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$symbol ${numFormat.format(c.statementAmount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: c.isPaid ? AppTheme.primaryLight : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          c.isPaid ? 'PAID' : 'DUE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: c.isPaid ? AppTheme.primaryLight : AppTheme.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        c.isPaid ? Icons.check_circle : Icons.circle_outlined,
                        color: c.isPaid ? AppTheme.primaryLight : AppTheme.textMuted,
                      ),
                      onPressed: () => repo.toggleCreditCardPaid(c.id),
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
