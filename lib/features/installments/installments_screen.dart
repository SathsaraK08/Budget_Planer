import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/installment_plan.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class InstallmentsScreen extends StatelessWidget {
  const InstallmentsScreen({super.key});

  void _showAddInstallmentDialog(BuildContext context) {
    final repo = context.read<BudgetRepository>();
    final itemController = TextEditingController();
    final vendorController = TextEditingController();
    final totalAmountController = TextEditingController();
    final monthlyController = TextEditingController();
    final remainingController = TextEditingController();
    String selectedPlatform = 'Koko';
    String selectedMemberId = repo.members.isNotEmpty ? repo.members.first.id : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            title: const Text('Add BNPL / Installment Plan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemController,
                    decoration: const InputDecoration(labelText: 'Item Name (e.g. Shoes, Filter)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vendorController,
                    decoration: const InputDecoration(labelText: 'Vendor / Store (e.g. Strong.lk, Dinapala)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPlatform,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'BNPL Platform'),
                    items: const [
                      DropdownMenuItem(value: 'Koko', child: Text('Koko')),
                      DropdownMenuItem(value: 'Mintpay', child: Text('Mintpay')),
                      DropdownMenuItem(value: 'PayZy', child: Text('PayZy')),
                      DropdownMenuItem(value: 'Commercial Bank', child: Text('Commercial Bank')),
                      DropdownMenuItem(value: 'Sampath Bank', child: Text('Sampath Bank')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPlatform = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMemberId,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Person / Member'),
                    items: repo.members.map((m) {
                      return DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.role})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMemberId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Total Cost (${repo.household.currencySymbol})'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: monthlyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Monthly Installment (${repo.household.currencySymbol})'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: remainingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Remaining Balance (${repo.household.currencySymbol})'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final total = double.tryParse(totalAmountController.text.trim()) ?? 0;
                  final monthly = double.tryParse(monthlyController.text.trim()) ?? 0;
                  final remaining = double.tryParse(remainingController.text.trim()) ?? monthly;
                  final item = itemController.text.trim();

                  if (monthly > 0 && item.isNotEmpty) {
                    repo.addInstallmentPlan(
                      InstallmentPlan(
                        id: const Uuid().v4(),
                        householdId: repo.household.id,
                        memberId: selectedMemberId,
                        platform: selectedPlatform,
                        itemName: item,
                        vendor: vendorController.text.trim().isNotEmpty ? vendorController.text.trim() : null,
                        totalAmount: total > 0 ? total : monthly * 3,
                        monthlyInstallment: monthly,
                        remainingBalance: remaining,
                        startDate: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Plan'),
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
    final plans = repo.installmentPlans;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final totalDueThisCycle = repo.currentMetrics.totalInstallmentsDue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BNPL & Installments (Koko / Mintpay)'),
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
                    const Text('INSTALLMENTS DUE THIS CYCLE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol ${numFormat.format(totalDueThisCycle)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.warning),
                    ),
                  ],
                ),
                const Icon(Icons.shopping_bag_outlined, size: 36, color: AppTheme.warning),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('ACTIVE PLANS PER PERSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),

          ...plans.map((p) {
            final member = repo.members.firstWhere(
              (m) => m.id == p.memberId,
              orElse: () => HouseholdMember(id: '', householdId: '', name: 'Household'),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p.platform,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              member.name,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => repo.toggleInstallmentPaid(p.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.isPaidInCurrentCycle ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: p.isPaidInCurrentCycle ? AppTheme.primary : AppTheme.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  p.isPaidInCurrentCycle ? Icons.check_circle : Icons.circle_outlined,
                                  size: 14,
                                  color: p.isPaidInCurrentCycle ? AppTheme.primaryLight : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  p.isPaidInCurrentCycle ? 'Paid This Cycle' : 'Mark Paid',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: p.isPaidInCurrentCycle ? AppTheme.primaryLight : AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.itemName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    if (p.vendor != null)
                      Text('Vendor: ${p.vendor}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: p.progressPercentage,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          p.remainingBalance <= 0 ? AppTheme.primaryLight : AppTheme.warning,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly: $symbol ${numFormat.format(p.monthlyInstallment)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'Remaining: $symbol ${numFormat.format(p.remainingBalance)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          p.continuesToNextCycle ? Icons.arrow_forward : Icons.task_alt,
                          size: 14,
                          color: p.continuesToNextCycle ? AppTheme.warning : AppTheme.primaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.continuesToNextCycle
                              ? 'Continues next cycle ($symbol ${numFormat.format(p.nextCycleDueAmount)})'
                              : 'Finishes this cycle! 🎉',
                          style: TextStyle(
                            fontSize: 11,
                            color: p.continuesToNextCycle ? AppTheme.warning : AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInstallmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
