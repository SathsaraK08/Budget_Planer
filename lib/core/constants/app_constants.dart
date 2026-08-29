import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Household Budget Planner';
  static const String appVersion = '1.0.0';
  
  // Default Cycle Configuration (25th of month to 24th/25th of next month)
  static const int defaultCycleStartDay = 25;
  static const String defaultCurrencySymbol = 'Rs.';
  static const String defaultCurrencyCode = 'LKR';
  
  // Storage keys
  static const String keySupabaseUrl = 'supabase_url';
  static const String keySupabaseAnonKey = 'supabase_anon_key';
  static const String keyGeminiApiKey = 'gemini_api_key';
  static const String keyCurrency = 'currency_code';
  static const String keyActiveMember = 'active_member_id';

  // Categories
  static const List<String> expenseCategories = [
    'Groceries',
    'Transport / PickMe',
    'Food & Dining',
    'Housing & Utilities',
    'Personal Care & Saloon',
    'Health & Gym',
    'Shopping / Clothes',
    'Kitchen Essentials',
    'Bathroom Essentials',
    'Subscriptions & Tech',
    'Loan & Credit Cards',
    'Other / Cash Reserve'
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Commercial Debit Card',
    'Sampath Card',
    'DFCC Card',
    'Fund Transfer (BOC / Bank)',
    'Other'
  ];

  static const List<String> wishlistCategories = [
    'Kitchen',
    'Bathroom',
    'Cosmetics & Beauty',
    'Electronics & Home',
    'Clothing & Lifestyle',
    'Other'
  ];

  static const List<String> bnplPlatforms = [
    'Koko',
    'Mintpay',
    'PayZy',
    'Commercial Bank Installment',
    'Sampath Bank Installment',
    'Other'
  ];
}
