import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/income_entry.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  void _showAddIncomeDialog(BuildContext context) {
    final repo = context.read<BudgetRepository>();
    final amountController = TextEditingController();
    final sourceController = TextEditingController(text: 'Salary');
    final notesController = TextEditingController();
    String selectedMemberId = repo.members.isNotEmpty ? repo.members.first.id : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            title: const Text('Add Income Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (${repo.household.currencySymbol})',
                      hintText: '249585.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sourceController,
                    decoration: const InputDecoration(labelText: 'Source (e.g. Salary, Bonus, Freelance)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMemberId,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Earned By'),
                    items: repo.members.map((m) {
                      return DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.role})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMemberId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim());
                  if (amount != null && amount > 0) {
                    repo.addIncomeEntry(
                      IncomeEntry(
                        id: const Uuid().v4(),
                        householdId: repo.household.id,
                        cycleId: repo.activeCycle?.id ?? 'default_cycle',
                        memberId: selectedMemberId,
                        source: sourceController.text.trim(),
                        amount: amount,
                        date: DateTime.now(),
                        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Income'),
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
    final entries = repo.incomeEntries;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final totalIncome = repo.currentMetrics.totalIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Income'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Income Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL CYCLE INCOME', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, letterSpacing: 1.1)),
                const SizedBox(height: 6),
                Text(
                  '$symbol ${numFormat.format(totalIncome)}',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logged for active cycle: ${repo.activeCycle?.formattedRange ?? ""}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('INCOME LOGS (HUSBAND & WIFE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),

          if (entries.isEmpty)
            const Center(child: Text('No income logged for this cycle.'))
          else
            ...entries.map((entry) {
              final member = repo.members.firstWhere(
                (m) => m.id == entry.memberId,
                orElse: () => HouseholdMember(id: '', householdId: '', name: 'Member'),
              );

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    child: const Icon(Icons.arrow_downward, color: AppTheme.primaryLight),
                  ),
                  title: Text(entry.source, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${member.name} • ${DateFormat('MMM dd, yyyy').format(entry.date)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+$symbol ${numFormat.format(entry.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                        onPressed: () => repo.deleteIncomeEntry(entry.id),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
