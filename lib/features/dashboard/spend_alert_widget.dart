import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/budget_repository.dart';
import '../../core/theme/app_theme.dart';

/// Percentile-based spend alert badge shown on Dashboard.
/// Compares current cycle spend to household's own historical distribution.
/// Shows "not enough data yet" when history < 3 cycles.
class SpendAlertWidget extends StatelessWidget {
  const SpendAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final alert = repo.computeSpendAlert();

    if (alert == null) return const SizedBox.shrink(); // Not enough data

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: alert.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alert.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(alert.icon, size: 14, color: alert.color),
          const SizedBox(width: 6),
          Text(
            alert.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: alert.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Result of the spend alert calculation.
class SpendAlert {
  final String level; // 'low' | 'medium' | 'high' | 'max'
  final String label;
  final Color color;
  final IconData icon;
  final double currentSpend;
  final double percentile;

  const SpendAlert({
    required this.level,
    required this.label,
    required this.color,
    required this.icon,
    required this.currentSpend,
    required this.percentile,
  });
}
