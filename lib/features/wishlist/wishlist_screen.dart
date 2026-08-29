import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/wishlist_item.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _showAddItemDialog(BuildContext context) {
    final repo = context.read<BudgetRepository>();
    final itemController = TextEditingController();
    final costController = TextEditingController();
    String selectedCategory = 'Kitchen';
    String selectedPriority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            title: const Text('Add Wishlist / Need to Buy Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemController,
                    decoration: const InputDecoration(labelText: 'Item Name (e.g. Potato Smasher, Air Fryer)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Estimated Cost (${repo.household.currencySymbol})',
                      hintText: '1500.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Kitchen', child: Text('Kitchen')),
                      DropdownMenuItem(value: 'Bathroom', child: Text('Bathroom')),
                      DropdownMenuItem(value: 'Cosmetics & Beauty', child: Text('Cosmetics & Beauty')),
                      DropdownMenuItem(value: 'Home & Tech', child: Text('Home & Tech')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    dropdownColor: AppTheme.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'high', child: Text('High Priority (Need immediately)')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                      DropdownMenuItem(value: 'low', child: Text('Low Priority (Can wait)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPriority = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final cost = double.tryParse(costController.text.trim()) ?? 0;
                  final item = itemController.text.trim();
                  if (item.isNotEmpty) {
                    repo.addWishlistItem(
                      WishlistItem(
                        id: const Uuid().v4(),
                        householdId: repo.household.id,
                        itemName: item,
                        category: selectedCategory,
                        estimatedCost: cost,
                        priority: selectedPriority,
                        isPlannedForCurrentCycle: false,
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Item'),
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
    final items = repo.wishlistItems;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');
    final plannedTotal = repo.currentMetrics.totalPlannedWishlist;

    // Group items by Category
    final categories = ['Kitchen', 'Bathroom', 'Cosmetics & Beauty', 'Home & Tech', 'Other'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist & Things to Buy'),
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
                    const Text('PLANNED FOR THIS CYCLE', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '$symbol ${numFormat.format(plannedTotal)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                    const SizedBox(height: 4),
                    const Text('Deducted from projected savings', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
                const Icon(Icons.checklist_rtl_outlined, size: 36, color: AppTheme.accent),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ...categories.map((cat) {
            final catItems = items.where((i) => i.category == cat).toList();
            if (catItems.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    cat.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppTheme.textSecondary),
                  ),
                ),
                ...catItems.map((item) {
                  return Card(
                    child: CheckboxListTile(
                      value: item.isPlannedForCurrentCycle,
                      activeColor: AppTheme.primary,
                      title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.priority == 'high'
                                  ? AppTheme.danger.withOpacity(0.2)
                                  : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.priority == 'high' ? AppTheme.danger : AppTheme.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.isPlannedForCurrentCycle ? 'Planned this cycle' : 'Not in this cycle',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      secondary: Text(
                        '$symbol ${numFormat.format(item.estimatedCost)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      onChanged: (_) => repo.toggleWishlistPlan(item.id),
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
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
