import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_repository.dart';
import '../../core/theme/app_theme.dart';

/// Categories Manager — one screen managing all three lookup lists.
/// Tabs: BNPL Platforms | Expense Categories | Wishlist Categories
/// Add / rename / delete for each. Matches Design Batch 4, Screen 4.
class CategoriesManagerScreen extends StatefulWidget {
  const CategoriesManagerScreen({super.key});

  @override
  State<CategoriesManagerScreen> createState() => _CategoriesManagerScreenState();
}

class _CategoriesManagerScreenState extends State<CategoriesManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _isLoading = false;

  List<String> _bnplPlatforms = [];
  List<String> _expenseCategories = [];
  List<String> _wishlistCategories = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = context.read<BudgetRepository>();
    final hhId = repo.household.id;

    final bnpl = await SupabaseRepository.fetchBnplPlatforms(hhId);
    final expense = await SupabaseRepository.fetchExpenseCategories(hhId);
    final wishlist = await SupabaseRepository.fetchWishlistCategories(hhId);

    if (mounted) {
      setState(() {
        _bnplPlatforms = bnpl;
        _expenseCategories = expense;
        _wishlistCategories = wishlist;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'BNPL'),
            Tab(text: 'Expenses'),
            Tab(text: 'Wishlist'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildList(
                  items: _bnplPlatforms,
                  table: 'lookup_bnpl_platforms',
                  onChanged: (updated) => setState(() => _bnplPlatforms = updated),
                  addHint: 'e.g. Koko, Mintpay, Frimi',
                ),
                _buildList(
                  items: _expenseCategories,
                  table: 'lookup_expense_categories',
                  onChanged: (updated) => setState(() => _expenseCategories = updated),
                  addHint: 'e.g. Groceries, Transport',
                ),
                _buildList(
                  items: _wishlistCategories,
                  table: 'lookup_wishlist_categories',
                  onChanged: (updated) => setState(() => _wishlistCategories = updated),
                  addHint: 'e.g. Kitchen, Electronics',
                ),
              ],
            ),
    );
  }

  Widget _buildList({
    required List<String> items,
    required String table,
    required void Function(List<String>) onChanged,
    required String addHint,
  }) {
    final repo = context.read<BudgetRepository>();
    final hhId = repo.household.id;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add item input
        Row(
          children: [
            Expanded(
              child: TextField(
                key: ValueKey(table),
                decoration: InputDecoration(
                  hintText: addHint,
                  prefixIcon: const Icon(Icons.add_outlined),
                ),
                onSubmitted: (value) async {
                  final name = value.trim();
                  if (name.isEmpty || items.contains(name)) return;
                  await SupabaseRepository.addLookupItem(table, hhId, name);
                  onChanged([...items, name]);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No items yet. Type above and press Enter to add.',
              style: TextStyle(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final name = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                title: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                leading: const Icon(Icons.drag_handle, color: AppTheme.textMuted, size: 18),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                  onPressed: () async {
                    final newList = [...items]..remove(name);
                    await SupabaseRepository.deleteLookupItem(table, hhId, name);
                    onChanged(newList);
                  },
                ),
              ),
            );
          }),
      ],
    );
  }
}
