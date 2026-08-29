import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/fixed_payment.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class FixedPaymentsScreen extends StatelessWidget {
  const FixedPaymentsScreen({super.key});

  void _showAddPaymentDialog(BuildContext context) {
    final repo = context.read<BudgetRepository>();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dueDayController = TextEditingController(text: '25');
    final transferDestController = TextEditingController(text: 'BOC Account');
    String selectedCategory = 'Housing';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            title: const Text('Add Fixed Payment / Bill'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Bill Name (e.g. Apartment Rent, Loan)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (${repo.household.currencySymbol})',
                      hintText: '70000.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dueDayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Due Day of Month (e.g. 25)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Housing', child: Text('Housing / Rent')),
                      DropdownMenuItem(value: 'Utilities', child: Text('Utilities (ECB/Water)')),
                      DropdownMenuItem(value: 'Loan', child: Text('Bank / Personal Loan')),
                      DropdownMenuItem(value: 'Insurance', child: Text('Insurance')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: transferDestController,
                    decoration: const InputDecoration(labelText: 'Destination (e.g. BOC Account)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim());
                  final name = nameController.text.trim();
                  final dueDay = int.tryParse(dueDayController.text.trim()) ?? 25;

                  if (amount != null && amount > 0 && name.isNotEmpty) {
                    repo.addFixedPayment(
                      FixedPayment(
                        id: const Uuid().v4(),
                        householdId: repo.household.id,
                        name: name,
                        amount: amount,
                        dueDayOfMonth: dueDay,
                        category: selectedCategory,
                        transferDestination: transferDestController.text.trim().isNotEmpty
                            ? transferDestController.text.trim()
                            : null,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Bill'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final payments = repo.fixedPayments;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final total = repo.currentMetrics.totalFixedBills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Bills & Loans'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Card
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
                    const Text('TOTAL MONTHLY FIXED BILLS', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol ${numFormat.format(total)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.danger),
                    ),
                  ],
                ),
                const Icon(Icons.home_work_outlined, size: 36, color: AppTheme.warning),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('RECURRING OBLIGATIONS (TAP TO MARK PAID)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),

          ...payments.map((p) {
            return Card(
              color: p.isPaid ? AppTheme.surface.withOpacity(0.6) : AppTheme.surface,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    p.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: p.isPaid ? AppTheme.primaryLight : AppTheme.textMuted,
                    size: 26,
                  ),
                  onPressed: () => repo.toggleFixedPaymentPaid(p.id),
                ),
                title: Text(
                  p.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: p.isPaid ? TextDecoration.lineThrough : null,
                    color: p.isPaid ? AppTheme.textMuted : AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Due Day: ${p.dueDayOfMonth}th • ${p.category}${p.transferDestination != null ? ' (${p.transferDestination})' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                trailing: Text(
                  '$symbol ${numFormat.format(p.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: p.isPaid ? AppTheme.primaryLight : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
