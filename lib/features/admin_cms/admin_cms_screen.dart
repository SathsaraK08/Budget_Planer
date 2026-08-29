import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/member.dart';
import '../../core/models/fixed_payment.dart';
import '../../core/models/installment_plan.dart';
import '../../core/models/subscription.dart';
import '../../core/models/credit_card.dart';
import '../../core/models/wishlist_item.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

class AdminCmsScreen extends StatefulWidget {
  const AdminCmsScreen({super.key});

  @override
  State<AdminCmsScreen> createState() => _AdminCmsScreenState();
}

class _AdminCmsScreenState extends State<AdminCmsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final symbol = repo.household.currencySymbol;
    final fmt = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('Admin CMS Control Panel'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.warning,
          labelColor: AppTheme.warning,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Members & Salaries'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Fixed Bills & Loans'),
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'BNPL / Koko Plans'),
            Tab(icon: Icon(Icons.subscriptions_outlined), text: 'Subscriptions & Cards'),
            Tab(icon: Icon(Icons.checklist_rtl_outlined), text: 'Wishlist CMS'),
            Tab(icon: Icon(Icons.tune), text: 'Core Parameters'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Members CMS
          _buildMembersCms(context, repo, symbol, fmt),

          // 2. Fixed Bills CMS
          _buildBillsCms(context, repo, symbol, fmt),

          // 3. BNPL CMS
          _buildBnplCms(context, repo, symbol, fmt),

          // 4. Subscriptions & Cards CMS
          _buildSubsAndCardsCms(context, repo, symbol, fmt),

          // 5. Wishlist CMS
          _buildWishlistCms(context, repo, symbol, fmt),

          // 6. Core Parameters CMS
          _buildSystemConfigCms(context, repo),
        ],
      ),
    );
  }

  Widget _buildMembersCms(BuildContext context, BudgetRepository repo, String symbol, NumberFormat fmt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('HOUSEHOLD MEMBERS & SALARIES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Member'),
              onPressed: () => _showMemberDialog(context, repo),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...repo.members.map((m) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(m.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
            ),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Role: ${m.role} • Regular Salary: $symbol ${fmt.format(m.regularMonthlySalary)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                  onPressed: () => _showMemberDialog(context, repo, member: m),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                  onPressed: () => repo.deleteMember(m.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBillsCms(BuildContext context, BudgetRepository repo, String symbol, NumberFormat fmt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('FIXED BILLS & RECURRING LOANS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Bill'),
              onPressed: () => _showBillDialog(context, repo),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...repo.fixedPayments.map((b) => Card(
          child: ListTile(
            title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Due: ${b.dueDayOfMonth}th • Category: ${b.category} • Dest: ${b.transferDestination ?? "Bank"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$symbol ${fmt.format(b.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                  onPressed: () => _showBillDialog(context, repo, bill: b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                  onPressed: () => repo.deleteFixedPayment(b.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBnplCms(BuildContext context, BudgetRepository repo, String symbol, NumberFormat fmt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('BNPL / KOKO / MINTPAY PLANS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Plan'),
              onPressed: () => _showBnplDialog(context, repo),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...repo.installmentPlans.map((p) => Card(
          child: ListTile(
            title: Text('${p.platform}: ${p.itemName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Monthly: $symbol ${fmt.format(p.monthlyInstallment)} • Balance: $symbol ${fmt.format(p.remainingBalance)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                  onPressed: () => _showBnplDialog(context, repo, plan: p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                  onPressed: () => repo.deleteInstallmentPlan(p.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSubsAndCardsCms(BuildContext context, BudgetRepository repo, String symbol, NumberFormat fmt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('SUBSCRIPTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        ...repo.subscriptions.map((s) => Card(
          child: ListTile(
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Billing Day: ${s.billingDay}th'),
            trailing: Text('$symbol ${fmt.format(s.amountLkr)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.info)),
          ),
        )),
        const SizedBox(height: 16),
        const Text('CREDIT CARDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        ...repo.creditCards.map((c) => Card(
          child: ListTile(
            title: Text(c.cardName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c.bankName} • Due: ${c.dueDay}th'),
            trailing: Text('$symbol ${fmt.format(c.statementAmount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary)),
          ),
        )),
      ],
    );
  }

  Widget _buildWishlistCms(BuildContext context, BudgetRepository repo, String symbol, NumberFormat fmt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('WISHLIST CMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Wishlist Item'),
              onPressed: () => _showWishlistDialog(context, repo),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...repo.wishlistItems.map((w) => Card(
          child: ListTile(
            title: Text(w.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${w.category} • Priority: ${w.priority.toUpperCase()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$symbol ${fmt.format(w.estimatedCost)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                  onPressed: () => repo.deleteWishlistItem(w.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSystemConfigCms(BuildContext context, BudgetRepository repo) {
    final nameController = TextEditingController(text: repo.household.name);
    final cycleDayController = TextEditingController(text: repo.household.cycleStartDay.toString());
    final symController = TextEditingController(text: repo.household.currencySymbol);
    final geminiController = TextEditingController(text: repo.household.geminiApiKey ?? '');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('CORE SYSTEM PARAMETERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Household Display Name')),
        const SizedBox(height: 12),
        TextField(controller: cycleDayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cycle Start Day of Month (Default: 25)')),
        const SizedBox(height: 12),
        TextField(controller: symController, decoration: const InputDecoration(labelText: 'Currency Symbol (e.g. Rs. or \$)')),
        const SizedBox(height: 12),
        TextField(controller: geminiController, obscureText: true, decoration: const InputDecoration(labelText: 'Gemini AI API Key (Free Tier)')),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save Core Configuration'),
          onPressed: () {
            final day = int.tryParse(cycleDayController.text.trim()) ?? 25;
            repo.updateHouseholdSettings(
              name: nameController.text.trim(),
              cycleStartDay: day,
              currencySymbol: symController.text.trim(),
              geminiKey: geminiController.text.trim().isNotEmpty ? geminiController.text.trim() : null,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuration saved!')),
            );
          },
        ),
      ],
    );
  }

  void _showMemberDialog(BuildContext context, BudgetRepository repo, {HouseholdMember? member}) {
    final isEdit = member != null;
    final nameCtrl = TextEditingController(text: isEdit ? member.name : '');
    final roleCtrl = TextEditingController(text: isEdit ? member.role : 'husband');
    final salaryCtrl = TextEditingController(text: isEdit ? member.regularMonthlySalary.toString() : '200000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Member' : 'Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role')),
            const SizedBox(height: 8),
            TextField(controller: salaryCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Regular Salary')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final salary = double.tryParse(salaryCtrl.text.trim()) ?? 0;
              if (isEdit) {
                repo.updateMember(member.copyWith(name: nameCtrl.text.trim(), role: roleCtrl.text.trim(), regularMonthlySalary: salary));
              } else {
                repo.addMember(HouseholdMember(id: const Uuid().v4(), householdId: repo.household.id, name: nameCtrl.text.trim(), role: roleCtrl.text.trim(), regularMonthlySalary: salary));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBillDialog(BuildContext context, BudgetRepository repo, {FixedPayment? bill}) {
    final isEdit = bill != null;
    final nameCtrl = TextEditingController(text: isEdit ? bill.name : '');
    final amtCtrl = TextEditingController(text: isEdit ? bill.amount.toString() : '');
    final dueCtrl = TextEditingController(text: isEdit ? bill.dueDayOfMonth.toString() : '25');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Bill' : 'Add Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
            const SizedBox(height: 8),
            TextField(controller: dueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Due Day')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
              final due = int.tryParse(dueCtrl.text.trim()) ?? 25;
              if (isEdit) {
                repo.updateFixedPayment(bill.copyWith(name: nameCtrl.text.trim(), amount: amt, dueDayOfMonth: due));
              } else {
                repo.addFixedPayment(FixedPayment(id: const Uuid().v4(), householdId: repo.household.id, name: nameCtrl.text.trim(), amount: amt, dueDayOfMonth: due));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBnplDialog(BuildContext context, BudgetRepository repo, {InstallmentPlan? plan}) {
    final isEdit = plan != null;
    final itemCtrl = TextEditingController(text: isEdit ? plan.itemName : '');
    final platCtrl = TextEditingController(text: isEdit ? plan.platform : 'Koko');
    final monthlyCtrl = TextEditingController(text: isEdit ? plan.monthlyInstallment.toString() : '');
    final remCtrl = TextEditingController(text: isEdit ? plan.remainingBalance.toString() : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit BNPL Plan' : 'Add BNPL Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 8),
            TextField(controller: platCtrl, decoration: const InputDecoration(labelText: 'Platform (Koko, Mintpay)')),
            const SizedBox(height: 8),
            TextField(controller: monthlyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Due')),
            const SizedBox(height: 8),
            TextField(controller: remCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Remaining Balance')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final monthly = double.tryParse(monthlyCtrl.text.trim()) ?? 0;
              final rem = double.tryParse(remCtrl.text.trim()) ?? 0;
              if (isEdit) {
                repo.updateInstallmentPlan(plan.copyWith(itemName: itemCtrl.text.trim(), platform: platCtrl.text.trim(), monthlyInstallment: monthly, remainingBalance: rem));
              } else {
                repo.addInstallmentPlan(InstallmentPlan(id: const Uuid().v4(), householdId: repo.household.id, itemName: itemCtrl.text.trim(), platform: platCtrl.text.trim(), monthlyInstallment: monthly, remainingBalance: rem, totalAmount: monthly * 3, startDate: DateTime.now()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWishlistDialog(BuildContext context, BudgetRepository repo) {
    final itemCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Wishlist Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 8),
            TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Cost')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costCtrl.text.trim()) ?? 0;
              repo.addWishlistItem(WishlistItem(id: const Uuid().v4(), householdId: repo.household.id, itemName: itemCtrl.text.trim(), estimatedCost: cost));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
