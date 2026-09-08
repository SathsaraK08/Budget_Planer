import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/budget_repository.dart';
import '../../core/services/supabase_repository.dart';
import '../../core/models/member.dart';
import '../../core/theme/app_theme.dart';

/// Household Members screen — list with add/edit/delete.
/// Delete is blocked with a clear message if the member has existing records.
/// Matches Design Batch 4, Screen 2.
class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({super.key});

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final members = repo.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members & Salaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add Member',
            onPressed: () => _showMemberSheet(context, repo, null),
          ),
        ],
      ),
      body: members.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _buildMemberCard(context, repo, members[i]),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 52, color: AppTheme.textMuted),
          SizedBox(height: 14),
          Text('No members yet', style: TextStyle(color: AppTheme.textSecondary)),
          SizedBox(height: 6),
          Text('Tap + to add a member', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, BudgetRepository repo, HouseholdMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            child: Text(
              member.name[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (member.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.regularMonthlySalary > 0
                      ? 'Rs. ${member.regularMonthlySalary.toStringAsFixed(0)} / month'
                      : 'No salary set',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 20),
                tooltip: 'Edit',
                onPressed: () => _showMemberSheet(context, repo, member),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, repo, member),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberSheet(BuildContext context, BudgetRepository repo, HouseholdMember? existing) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final salaryCtrl = TextEditingController(
      text: existing?.regularMonthlySalary != null && existing!.regularMonthlySalary > 0
          ? existing.regularMonthlySalary.toStringAsFixed(0)
          : '',
    );
    bool isAdmin = existing?.isAdmin ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Add Member' : 'Edit Member',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: salaryCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(
                  labelText: 'Monthly Salary',
                  prefixText: 'Rs. ',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Admin access', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: const Text('Can manage Settings', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                value: isAdmin,
                activeColor: AppTheme.primary,
                onChanged: (val) => setModalState(() => isAdmin = val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final salary = double.tryParse(salaryCtrl.text.replaceAll(',', '')) ?? 0.0;

                    if (existing == null) {
                      final newMember = HouseholdMember(
                        id: _uuid.v4(),
                        householdId: repo.household.id,
                        name: name,
                        role: isAdmin ? 'admin' : 'member',
                        isAdmin: isAdmin,
                        regularMonthlySalary: salary,
                      );
                      final saved = await SupabaseRepository.addMember(newMember);
                      repo.addMember(saved ?? newMember);
                    } else {
                      final updated = existing.copyWith(
                        name: name,
                        role: isAdmin ? 'admin' : 'member',
                        isAdmin: isAdmin,
                        regularMonthlySalary: salary,
                      );
                      await SupabaseRepository.updateMember(updated);
                      repo.updateMember(updated);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Add Member' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    salaryCtrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, BudgetRepository repo, HouseholdMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Member'),
        content: Text(
          'Are you sure you want to remove ${member.name}?\n\n'
          'If this member has linked expense or income records, the delete will be blocked.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    // Safe delete via DB RPC — checks FK constraints
    final result = await SupabaseRepository.safeDeleteMember(member.id, repo.household.id);

    if (!mounted) return;

    if (result == 'deleted') {
      repo.deleteMember(member.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.name} removed.'), behavior: SnackBarBehavior.floating),
      );
    } else if (result.startsWith('blocked')) {
      final count = result.split(':').lastOrNull ?? '?';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.name} cannot be deleted — they have $count linked expense/income records. '
            'Remove those records first, or reassign them.',
          ),
          backgroundColor: AppTheme.warning,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == 'unauthorized') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can delete members.'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Offline mode — do local delete only (no FK check possible)
      repo.deleteMember(member.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.name} removed (offline mode).'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
