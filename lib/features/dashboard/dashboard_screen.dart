import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';
import '../daily_spends/quick_spend_dialog.dart';
import '../forecast/forecast_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final cycle = repo.activeCycle;
    final metrics = repo.currentMetrics;
    final forecast = repo.nextForecast;
    final symbol = repo.household.currencySymbol;
    final numFormat = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              repo.household.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (cycle != null)
              Text(
                'Cycle: ${cycle.formattedRange} (${cycle.daysRemaining} days left)',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined, color: AppTheme.primaryLight),
            tooltip: 'View Next Month Survival Forecast',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForecastScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => repo.refreshAiAdvice(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cycle Health & Progress Banner
              _buildCycleProgressBanner(context, cycle, metrics, forecast, symbol, numFormat),
              const SizedBox(height: 16),

              // 2. AI Advisor / Survival Insight Banner
              _buildAiInsightCard(context, repo),
              const SizedBox(height: 16),

              // 3. Four Core Metric Cards
              _buildMetricCardsGrid(metrics, symbol, numFormat),
              const SizedBox(height: 20),

              // 4. Household Member Filter
              _buildMemberSelector(repo),
              const SizedBox(height: 20),

              // 5. Outgoings Breakdown Summary
              _buildCommitmentsSummary(context, repo, metrics, symbol, numFormat),
              const SizedBox(height: 20),

              // 6. Recent Daily Spends
              _buildRecentSpendsSection(context, repo, symbol, numFormat),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Log Spend (Cash/Card)'),
        backgroundColor: AppTheme.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const QuickSpendDialog(),
          );
        },
      ),
    );
  }

  Widget _buildCycleProgressBanner(
    BuildContext context,
    dynamic cycle,
    dynamic metrics,
    dynamic forecast,
    String symbol,
    NumberFormat fmt,
  ) {
    final remaining = metrics.remainingBalance;
    final isNegative = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegative
              ? [const Color(0xFF450A0A), const Color(0xFF1F2937)]
              : [const Color(0xFF064E3B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNegative ? AppTheme.danger.withOpacity(0.5) : AppTheme.primary.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'REALTIME REMAINING BALANCE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: forecast.hasShortfall ? AppTheme.warning.withOpacity(0.2) : AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: forecast.hasShortfall ? AppTheme.warning : AppTheme.primary,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  forecast.hasShortfall ? '⚠️ Next Month Shortfall' : '✅ Healthy Surplus',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: forecast.hasShortfall ? AppTheme.warning : AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$symbol ${fmt.format(remaining)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isNegative ? AppTheme.danger : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Projected Savings at Cycle End: ',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                '$symbol ${fmt.format(metrics.projectedSavings)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context, BudgetRepository repo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppTheme.secondary),
              const SizedBox(width: 8),
              const Text(
                'AI Advisor Guidance',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13),
              ),
              const Spacer(),
              if (repo.isLoadingAdvice)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondary),
                )
              else
                InkWell(
                  onTap: () => repo.refreshAiAdvice(),
                  child: const Icon(Icons.refresh, size: 16, color: AppTheme.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            repo.aiAdvice.isEmpty ? 'Analyzing your cycle commitments and survival projection...' : repo.aiAdvice,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsGrid(dynamic metrics, String symbol, NumberFormat fmt) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildMetricItem(
          title: 'Total Income',
          value: '$symbol ${fmt.format(metrics.totalIncome)}',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppTheme.primaryLight,
          subtitle: 'Husband & Wife Combined',
        ),
        _buildMetricItem(
          title: 'Committed Outgoings',
          value: '$symbol ${fmt.format(metrics.totalCommittedOutgoings)}',
          icon: Icons.receipt_long_outlined,
          iconColor: AppTheme.warning,
          subtitle: 'Rent, Loans, Koko, CC, Subs',
        ),
        _buildMetricItem(
          title: 'Daily Spent So Far',
          value: '$symbol ${fmt.format(metrics.totalDailySpent)}',
          icon: Icons.shopping_bag_outlined,
          iconColor: AppTheme.info,
          subtitle: 'Cash: ${fmt.format(metrics.totalCashSpent)} | Card: ${fmt.format(metrics.totalCardSpent)}',
        ),
        _buildMetricItem(
          title: 'Planned Wishlist',
          value: '$symbol ${fmt.format(metrics.totalPlannedWishlist)}',
          icon: Icons.checklist_outlined,
          iconColor: AppTheme.accent,
          subtitle: 'Active shopping items',
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
              ),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelector(BudgetRepository repo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOUSEHOLD MEMBERS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: repo.members.map((member) {
            final isSelected = repo.selectedMemberId == member.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  '${member.name} (${member.role})',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primary.withOpacity(0.3),
                checkmarkColor: AppTheme.primaryLight,
                onSelected: (_) => repo.setSelectedMember(member.id),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommitmentsSummary(
    BuildContext context,
    BudgetRepository repo,
    dynamic metrics,
    String symbol,
    NumberFormat fmt,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CYCLE COMMITTED OUTGOINGS BREAKDOWN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          _buildOutgoingRow('Fixed Bills (Rent, Utilities, Loans)', metrics.totalFixedBills, symbol, fmt, AppTheme.danger),
          _buildOutgoingRow('BNPL Installments (Koko, Mintpay, Payzy)', metrics.totalInstallmentsDue, symbol, fmt, AppTheme.warning),
          _buildOutgoingRow('Credit Card Statements', metrics.totalCreditCardDues, symbol, fmt, AppTheme.secondary),
          _buildOutgoingRow('Subscriptions (Dialog, Netflix, Apple)', metrics.totalSubscriptions, symbol, fmt, AppTheme.info),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Committed Outgoings', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(
                '$symbol ${fmt.format(metrics.totalCommittedOutgoings)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingRow(String label, double amount, String symbol, NumberFormat fmt, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Text(
            '$symbol ${fmt.format(amount)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSpendsSection(
    BuildContext context,
    BudgetRepository repo,
    String symbol,
    NumberFormat fmt,
  ) {
    final spends = repo.dailySpends.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT DAILY SPENDS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppTheme.textSecondary),
            ),
            Text(
              '${repo.dailySpends.length} Total Logs',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (spends.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No daily spends logged for this cycle yet.', style: TextStyle(color: AppTheme.textMuted)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: spends.length,
            itemBuilder: (context, index) {
              final item = spends[index];
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
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    '${item.formattedDate} • ${item.category} (${item.paymentMethod})',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  trailing: Text(
                    '-$symbol ${fmt.format(item.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.danger),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
