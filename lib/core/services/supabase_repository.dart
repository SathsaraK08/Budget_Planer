import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/household.dart';
import '../models/member.dart';
import '../models/income_entry.dart';
import '../models/fixed_payment.dart';
import '../models/installment_plan.dart';
import '../models/subscription.dart';
import '../models/wishlist_item.dart';
import '../models/daily_spend.dart';
import '../models/forecast_settings.dart';
import '../models/cycle.dart';
import 'supabase_service.dart';

/// All Supabase DB interactions in one place.
/// BudgetRepository delegates to this when Supabase is configured.
/// Every method is guarded — if Supabase is not configured, returns null/empty silently.
class SupabaseRepository {
  static SupabaseClient get _db => SupabaseService.client;

  // ── Household ────────────────────────────────────────────────────────────────

  /// Fetch the household the currently authenticated user belongs to.
  static Future<Household?> fetchMyHousehold() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return null;

      // Join via household_members to find our household
      final memberRow = await _db
          .from('household_members')
          .select('household_id')
          .eq('user_id', uid)
          .maybeSingle();

      if (memberRow == null) return null;
      final hhId = memberRow['household_id'] as String;

      final hhRow = await _db
          .from('households')
          .select('*')
          .eq('id', hhId)
          .single();

      return Household.fromJson(hhRow);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateHousehold(Household h) async {
    try {
      await _db.from('households').update(h.toJson()).eq('id', h.id);
    } catch (_) {}
  }

  /// Mark setup_completed = true in DB (fixes setup-loop bug).
  static Future<void> completeSetup(String householdId) async {
    try {
      await _db.rpc('complete_setup', params: {'p_household_id': householdId});
    } catch (_) {}
  }

  // ── Members ──────────────────────────────────────────────────────────────────

  static Future<List<HouseholdMember>> fetchMembers(String householdId) async {
    try {
      final rows = await _db
          .from('household_members')
          .select('*')
          .eq('household_id', householdId)
          .order('created_at');
      return rows.map((r) => HouseholdMember.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<HouseholdMember?> addMember(HouseholdMember m) async {
    try {
      final row = await _db
          .from('household_members')
          .insert(m.toJson()..remove('id'))
          .select()
          .single();
      return HouseholdMember.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateMember(HouseholdMember m) async {
    try {
      await _db.from('household_members').update(m.toJson()).eq('id', m.id);
    } catch (_) {}
  }

  /// Safe delete: calls DB RPC that checks FK constraints first.
  /// Returns 'deleted', 'blocked:N' (N = linked records), or 'unauthorized'/'error'.
  static Future<String> safeDeleteMember(String memberId, String householdId) async {
    try {
      final result = await _db.rpc('safe_delete_member', params: {
        'p_member_id': memberId,
        'p_household_id': householdId,
      });
      return result as String? ?? 'error';
    } catch (e) {
      return 'error: $e';
    }
  }

  // ── Auth / Household Registration ────────────────────────────────────────────

  /// Register a new user + household atomically via the claim_household RPC.
  static Future<String?> claimHousehold({
    required String householdName,
    required String userName,
    String? partnerName,
  }) async {
    try {
      final result = await _db.rpc('claim_household', params: {
        'new_household_name': householdName,
        'user_name': userName,
        'user_role': 'admin',
        'partner_name': partnerName ?? '',
      });
      return result as String?;
    } catch (e) {
      return null;
    }
  }

  // ── Cycles ───────────────────────────────────────────────────────────────────

  static Future<List<BudgetCycle>> fetchCycles(String householdId) async {
    try {
      final rows = await _db
          .from('cycles')
          .select('*')
          .eq('household_id', householdId)
          .order('start_date', ascending: false);
      return rows.map((r) => BudgetCycle.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<BudgetCycle?> upsertCycle(BudgetCycle cycle) async {
    try {
      final row = await _db
          .from('cycles')
          .upsert(cycle.toJson())
          .select()
          .single();
      return BudgetCycle.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  // ── Income ───────────────────────────────────────────────────────────────────

  static Future<List<IncomeEntry>> fetchIncomeEntries(String householdId) async {
    try {
      final rows = await _db
          .from('income_entries')
          .select('*')
          .eq('household_id', householdId)
          .order('date', ascending: false);
      return rows.map((r) => IncomeEntry.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<IncomeEntry?> addIncomeEntry(IncomeEntry e) async {
    try {
      final map = e.toJson()..remove('id');
      final row = await _db.from('income_entries').insert(map).select().single();
      return IncomeEntry.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteIncomeEntry(String id) async {
    try {
      await _db.from('income_entries').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Fixed Payments ───────────────────────────────────────────────────────────

  static Future<List<FixedPayment>> fetchFixedPayments(String householdId) async {
    try {
      final rows = await _db
          .from('fixed_payments')
          .select('*')
          .eq('household_id', householdId)
          .order('due_day_of_month');
      return rows.map((r) => FixedPayment.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<FixedPayment?> addFixedPayment(FixedPayment p) async {
    try {
      final map = p.toJson()..remove('id');
      final row = await _db.from('fixed_payments').insert(map).select().single();
      return FixedPayment.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateFixedPayment(FixedPayment p) async {
    try {
      await _db.from('fixed_payments').update(p.toJson()).eq('id', p.id);
    } catch (_) {}
  }

  static Future<void> deleteFixedPayment(String id) async {
    try {
      await _db.from('fixed_payments').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Installments ─────────────────────────────────────────────────────────────

  static Future<List<InstallmentPlan>> fetchInstallments(String householdId) async {
    try {
      final rows = await _db
          .from('installment_plans')
          .select('*')
          .eq('household_id', householdId)
          .order('due_day_of_month');
      return rows.map((r) => InstallmentPlan.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<InstallmentPlan?> addInstallment(InstallmentPlan p) async {
    try {
      final map = p.toJson()..remove('id');
      final row = await _db.from('installment_plans').insert(map).select().single();
      return InstallmentPlan.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateInstallment(InstallmentPlan p) async {
    try {
      await _db.from('installment_plans').update(p.toJson()).eq('id', p.id);
    } catch (_) {}
  }

  static Future<void> deleteInstallment(String id) async {
    try {
      await _db.from('installment_plans').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Subscriptions ────────────────────────────────────────────────────────────

  static Future<List<Subscription>> fetchSubscriptions(String householdId) async {
    try {
      final rows = await _db
          .from('subscriptions')
          .select('*')
          .eq('household_id', householdId)
          .order('billing_day');
      return rows.map((r) => Subscription.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Subscription?> addSubscription(Subscription s) async {
    try {
      final map = s.toJson()..remove('id');
      final row = await _db.from('subscriptions').insert(map).select().single();
      return Subscription.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateSubscription(Subscription s) async {
    try {
      await _db.from('subscriptions').update(s.toJson()).eq('id', s.id);
    } catch (_) {}
  }

  static Future<void> deleteSubscription(String id) async {
    try {
      await _db.from('subscriptions').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Wishlist ─────────────────────────────────────────────────────────────────

  static Future<List<WishlistItem>> fetchWishlistItems(String householdId) async {
    try {
      final rows = await _db
          .from('wishlist_items')
          .select('*')
          .eq('household_id', householdId)
          .order('created_at', ascending: false);
      return rows.map((r) => WishlistItem.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<WishlistItem?> addWishlistItem(WishlistItem w) async {
    try {
      final map = w.toJson()..remove('id');
      final row = await _db.from('wishlist_items').insert(map).select().single();
      return WishlistItem.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateWishlistItem(WishlistItem w) async {
    try {
      await _db.from('wishlist_items').update(w.toJson()).eq('id', w.id);
    } catch (_) {}
  }

  static Future<void> deleteWishlistItem(String id) async {
    try {
      await _db.from('wishlist_items').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Daily Spends ─────────────────────────────────────────────────────────────

  static Future<List<DailySpend>> fetchDailySpends(String householdId) async {
    try {
      final rows = await _db
          .from('daily_spends')
          .select('*')
          .eq('household_id', householdId)
          .order('date', ascending: false)
          .order('created_at', ascending: false);
      return rows.map((r) => DailySpend.fromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<DailySpend?> addDailySpend(DailySpend s) async {
    try {
      final map = s.toJson()..remove('id');
      final row = await _db.from('daily_spends').insert(map).select().single();
      return DailySpend.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteDailySpend(String id) async {
    try {
      await _db.from('daily_spends').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Forecast Settings ─────────────────────────────────────────────────────────

  static Future<ForecastSettings> fetchForecastSettings(String householdId) async {
    try {
      final row = await _db
          .from('forecast_settings')
          .select('*')
          .eq('household_id', householdId)
          .maybeSingle();
      if (row == null) return const ForecastSettings();
      return ForecastSettings.fromJson(row);
    } catch (_) {
      return const ForecastSettings();
    }
  }

  static Future<void> updateForecastSettings(String householdId, ForecastSettings s) async {
    try {
      await _db.from('forecast_settings').upsert({
        'household_id': householdId,
        ...s.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // ── AI Settings ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchAiSettings(String householdId) async {
    try {
      return await _db
          .from('ai_settings')
          .select('*')
          .eq('household_id', householdId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateAiSettings(String householdId, String provider, String? apiKey) async {
    try {
      await _db.from('ai_settings').upsert({
        'household_id': householdId,
        'provider': provider,
        'api_key': apiKey,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // ── Lookup Lists ──────────────────────────────────────────────────────────────

  static Future<List<String>> fetchBnplPlatforms(String householdId) async {
    try {
      final rows = await _db
          .from('lookup_bnpl_platforms')
          .select('name')
          .eq('household_id', householdId)
          .order('sort_order');
      return rows.map((r) => r['name'] as String).toList();
    } catch (_) {
      return ['Koko', 'Mintpay', 'PayZy', 'Frimi', 'Other'];
    }
  }

  static Future<List<String>> fetchExpenseCategories(String householdId) async {
    try {
      final rows = await _db
          .from('lookup_expense_categories')
          .select('name')
          .eq('household_id', householdId)
          .order('sort_order');
      return rows.map((r) => r['name'] as String).toList();
    } catch (_) {
      return ['Groceries', 'Food & Dining', 'Transport / PickMe', 'Health & Gym',
              'Personal Care & Saloon', 'Entertainment', 'Other / Cash Reserve'];
    }
  }

  static Future<List<String>> fetchWishlistCategories(String householdId) async {
    try {
      final rows = await _db
          .from('lookup_wishlist_categories')
          .select('name')
          .eq('household_id', householdId)
          .order('sort_order');
      return rows.map((r) => r['name'] as String).toList();
    } catch (_) {
      return ['Kitchen', 'Bathroom', 'Electronics', 'Clothing', 'Home Appliances', 'Other'];
    }
  }

  static Future<void> addLookupItem(String table, String householdId, String name) async {
    try {
      final existing = await _db
          .from(table)
          .select('sort_order')
          .eq('household_id', householdId)
          .order('sort_order', ascending: false)
          .limit(1);
      final nextOrder = existing.isEmpty ? 1 : (existing.first['sort_order'] as int) + 1;
      await _db.from(table).insert({
        'household_id': householdId,
        'name': name,
        'sort_order': nextOrder,
      });
    } catch (_) {}
  }

  static Future<void> deleteLookupItem(String table, String householdId, String name) async {
    try {
      await _db.from(table).delete()
          .eq('household_id', householdId)
          .eq('name', name);
    } catch (_) {}
  }
}
