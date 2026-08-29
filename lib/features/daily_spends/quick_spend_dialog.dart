import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/daily_spend.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class QuickSpendDialog extends StatefulWidget {
  const QuickSpendDialog({super.key});

  @override
  State<QuickSpendDialog> createState() => _QuickSpendDialogState();
}

class _QuickSpendDialogState extends State<QuickSpendDialog> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = AppConstants.expenseCategories.first;
  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    final title = _titleController.text.trim();

    if (amount == null || amount <= 0 || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount and title.')),
      );
      return;
    }

    final repo = context.read<BudgetRepository>();
    final newSpend = DailySpend(
      id: const Uuid().v4(),
      householdId: repo.household.id,
      cycleId: repo.activeCycle?.id ?? 'default_cycle',
      memberId: repo.selectedMemberId,
      date: _selectedDate,
      amount: amount,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      title: title,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    repo.addDailySpend(newSpend);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final symbol = repo.household.currencySymbol;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚡ Quick Log Daily Spend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
              decoration: InputDecoration(
                prefixText: '$symbol ',
                prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                labelText: 'Spend Amount',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 12),

            // Title / Description
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'What was this for?',
                hintText: 'e.g. Food City Groceries, PickMe Tuk, Coffee',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Segmented Choice
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(method),
                  selected: isSelected,
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedPaymentMethod = method);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Chips
            const Text(
              'CATEGORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AppConstants.expenseCategories.take(8).map((cat) {
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: AppTheme.secondary.withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save Expense', style: TextStyle(fontSize: 16)),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
