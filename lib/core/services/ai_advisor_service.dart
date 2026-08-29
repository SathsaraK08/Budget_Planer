import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_result.dart';
import '../models/cycle.dart';

class AIAdvisorService {
  /// Generates plain-language financial guidance from deterministic numbers.
  /// Strict rule: AI NEVER computes financial totals; it strictly interprets the rule engine's output.
  static Future<String> generateCycleAdvice({
    required CurrentCycleMetrics currentMetrics,
    required NextCycleForecast nextForecast,
    required BudgetCycle activeCycle,
    required String currencySymbol,
    String? apiKey,
  }) async {
    // If no API key is provided, generate high-quality smart rule-based guidance
    if (apiKey == null || apiKey.trim().isEmpty) {
      return _generateLocalSmartAdvice(currentMetrics, nextForecast, activeCycle, currencySymbol);
    }

    try {
      final prompt = '''
You are a wise, supportive household financial advisor for a 2-person household.
Analyze the following PRE-CALCULATED financial metrics for the cycle (${activeCycle.formattedRange}):

Current Cycle Numbers:
- Total Income: $currencySymbol ${currentMetrics.totalIncome.toStringAsFixed(0)}
- Total Committed Fixed Outgoings: $currencySymbol ${currentMetrics.totalCommittedOutgoings.toStringAsFixed(0)}
- Daily Spent so far: $currencySymbol ${currentMetrics.totalDailySpent.toStringAsFixed(0)} (Cash: $currencySymbol ${currentMetrics.totalCashSpent.toStringAsFixed(0)}, Card: $currencySymbol ${currentMetrics.totalCardSpent.toStringAsFixed(0)})
- Planned Wishlist Items: $currencySymbol ${currentMetrics.totalPlannedWishlist.toStringAsFixed(0)}
- Realtime Remaining Balance: $currencySymbol ${currentMetrics.remainingBalance.toStringAsFixed(0)}
- Projected End-of-Cycle Savings: $currencySymbol ${currentMetrics.projectedSavings.toStringAsFixed(0)}
- Days remaining in cycle: ${activeCycle.daysRemaining} days

Next Cycle Forward-Looking Forecast:
- Next Cycle Estimated Income: $currencySymbol ${nextForecast.estimatedIncome.toStringAsFixed(0)}
- Next Cycle Committed Costs: $currencySymbol ${nextForecast.totalEstimatedCommitted.toStringAsFixed(0)}
- Next Cycle Projected Balance: $currencySymbol ${nextForecast.projectedNetBalance.toStringAsFixed(0)}
- Has Shortfall: ${nextForecast.hasShortfall ? "YES (Short by $currencySymbol ${nextForecast.shortfallAmount.toStringAsFixed(0)})" : "NO (Surplus of $currencySymbol ${nextForecast.projectedNetBalance.toStringAsFixed(0)})"}
- Required Survival Reserve Buffer: $currencySymbol ${nextForecast.requiredSurvivalBuffer.toStringAsFixed(0)}
- Installments ending this cycle: ${nextForecast.completedInstallmentsCount}
- Installments continuing: ${nextForecast.continuingInstallmentsCount}
- Top Commitments: ${nextForecast.highCommitmentFactors.join(', ')}

Please provide:
1. A concise 2-sentence summary of their current financial position.
2. A direct recommendation regarding whether to buy planned wishlist items this cycle or defer them.
3. If there is a shortfall next cycle, state the exact buffer they must keep in reserve from this month.
Keep your response friendly, clear, and under 150 words. Do not recalculate numbers.
''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 300,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (text != null && text.isNotEmpty) {
          return text.trim();
        }
      }
    } catch (e) {
      // Fallback to local advice on network error
    }

    return _generateLocalSmartAdvice(currentMetrics, nextForecast, activeCycle, currencySymbol);
  }

  static String _generateLocalSmartAdvice(
    CurrentCycleMetrics current,
    NextCycleForecast next,
    BudgetCycle cycle,
    String symbol,
  ) {
    final buffer = StringBuffer();

    if (next.hasShortfall) {
      buffer.writeln(
        '⚠️ **Warning: Next Cycle Shortfall Detected!** Next cycle is projected to be short by $symbol ${next.shortfallAmount.toStringAsFixed(0)} due to commitments ($symbol ${next.totalEstimatedCommitted.toStringAsFixed(0)}).',
      );
      buffer.writeln(
        '💡 **Survival Action:** Reserve at least $symbol ${next.requiredSurvivalBuffer.toStringAsFixed(0)} from your current remaining balance ($symbol ${current.remainingBalance.toStringAsFixed(0)}) to guarantee smooth survival without debt.',
      );
      if (current.totalPlannedWishlist > 0) {
        buffer.writeln(
          '🛑 **Wishlist Advice:** Delay non-essential wishlist purchases ($symbol ${current.totalPlannedWishlist.toStringAsFixed(0)}) until next month\'s installments finish.',
        );
      }
    } else {
      buffer.writeln(
        '✅ **Healthy Budget Position:** You have a safe remaining balance of $symbol ${current.remainingBalance.toStringAsFixed(0)} with ${cycle.daysRemaining} days left.',
      );
      if (next.completedInstallmentsCount > 0) {
        buffer.writeln(
          '🎉 **Good News:** ${next.completedInstallmentsCount} installment plan(s) finish this cycle, freeing up cash flow for next month!',
        );
      }
      buffer.writeln(
        '📈 Next cycle has a projected surplus of $symbol ${next.projectedNetBalance.toStringAsFixed(0)}. Your planned wishlist purchases ($symbol ${current.totalPlannedWishlist.toStringAsFixed(0)}) are within safe limits.',
      );
    }

    return buffer.toString().trim();
  }
}
