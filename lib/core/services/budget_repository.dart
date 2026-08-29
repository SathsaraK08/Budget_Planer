import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/household.dart';
import '../models/member.dart';
import '../models/cycle.dart';
import '../models/income_entry.dart';
import '../models/fixed_payment.dart';
import '../models/installment_plan.dart';
import '../models/credit_card.dart';
import '../models/subscription.dart';
import '../models/wishlist_item.dart';
import '../models/daily_spend.dart';
import '../models/forecast_result.dart';
import '../engine/budget_engine.dart';
import 'ai_advisor_service.dart';

class BudgetRepository extends ChangeNotifier {
  final _uuid = const Uuid();

  // Active State
  Household _household = Household(
    id: 'a0000000-0000-0000-0000-000000000001',
    name: 'Our Household',
    currencySymbol: 'Rs.',
    currencyCode: 'LKR',
    cycleStartDay: 25,
  );

  // User Profile
  String _userName = 'Sathsara';
  String _userEmail = 'admin@homebudget.lk';
  String _userRole = 'husband';
  bool _isAdmin = true;

  List<HouseholdMember> _members = [];
  List<BudgetCycle> _cycles = [];
  BudgetCycle? _activeCycle;

  List<IncomeEntry> _incomeEntries = [];
  List<FixedPayment> _fixedPayments = [];
  List<InstallmentPlan> _installmentPlans = [];
  List<CreditCard> _creditCards = [];
  List<Subscription> _subscriptions = [];
  List<WishlistItem> _wishlistItems = [];
  List<DailySpend> _dailySpends = [];

  String? _selectedMemberId;
  String _aiAdvice = '';
  bool _isLoadingAdvice = false;

  // Getters
  Household get household => _household;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  bool get isAdmin => _isAdmin;

  List<HouseholdMember> get members => _members;
  List<BudgetCycle> get cycles => _cycles;
  BudgetCycle? get activeCycle => _activeCycle;

  List<IncomeEntry> get incomeEntries => _incomeEntries;
  List<FixedPayment> get fixedPayments => _fixedPayments;
  List<InstallmentPlan> get installmentPlans => _installmentPlans;
  List<CreditCard> get creditCards => _creditCards;
  List<Subscription> get subscriptions => _subscriptions;
  List<WishlistItem> get wishlistItems => _wishlistItems;
  List<DailySpend> get dailySpends => _dailySpends;

  String? get selectedMemberId => _selectedMemberId;
  String get aiAdvice => _aiAdvice;
  bool get isLoadingAdvice => _isLoadingAdvice;

  // Cached Calculated Engine Results
  CurrentCycleMetrics get currentMetrics {
    return BudgetEngine.calculateCurrentCycleMetrics(
      incomeEntries: _incomeEntries,
      fixedPayments: _fixedPayments,
      installmentPlans: _installmentPlans,
      creditCards: _creditCards,
      subscriptions: _subscriptions,
      dailySpends: _dailySpends,
      wishlistItems: _wishlistItems,
    );
  }

  NextCycleForecast get nextForecast {
    return BudgetEngine.calculateNextCycleForecast(
      members: _members,
      fixedPayments: _fixedPayments,
      installmentPlans: _installmentPlans,
      subscriptions: _subscriptions,
    );
  }

  BudgetRepository() {
    _loadInitialSampleData();
  }

  void setUserProfile({required String name, required String email, required String role, required bool isAdmin}) {
    _userName = name;
    _userEmail = email;
    _userRole = role;
    _isAdmin = isAdmin;
    notifyListeners();
  }

  Future<void> _loadInitialSampleData() async {
    final now = DateTime(2026, 8, 25);
    final startDate = DateTime(2026, 8, 25);
    final endDate = DateTime(2026, 9, 24);

    _activeCycle = BudgetCycle(
      id: 'c0000000-0000-0000-0000-000000000001',
      householdId: _household.id,
      name: 'Aug 25 - Sep 25, 2026',
      startDate: startDate,
      endDate: endDate,
      status: 'open',
    );
    _cycles = [_activeCycle!];

    // Members
    final selfMember = HouseholdMember(
      id: 'b0000000-0000-0000-0000-000000000001',
      householdId: _household.id,
      name: 'Sathsara',
      role: 'husband',
      avatarColor: '#10B981',
      regularMonthlySalary: 249585.0,
    );

    final wifeMember = HouseholdMember(
      id: 'b0000000-0000-0000-0000-000000000002',
      householdId: _household.id,
      name: 'Dhiyan',
      role: 'wife',
      avatarColor: '#EC4899',
      regularMonthlySalary: 150000.0,
    );

    _members = [selfMember, wifeMember];
    _selectedMemberId = selfMember.id;

    // Income
    _incomeEntries = [
      IncomeEntry(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        memberId: selfMember.id,
        source: 'Salary',
        amount: 249585.0,
        date: DateTime(2026, 8, 24),
        notes: 'Monthly IT salary',
      ),
      IncomeEntry(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        memberId: wifeMember.id,
        source: 'Salary',
        amount: 150000.0,
        date: DateTime(2026, 8, 25),
        notes: 'Monthly salary',
      ),
    ];

    // Fixed Payments
    _fixedPayments = [
      FixedPayment(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Apartment Rent',
        amount: 70000.0,
        dueDayOfMonth: 25,
        category: 'Housing',
        transferDestination: 'BOC Account',
        isPaid: true,
        paidDate: '2026-08-26',
      ),
      FixedPayment(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Apartment ECB + Water',
        amount: 20000.0,
        dueDayOfMonth: 25,
        category: 'Utilities',
        transferDestination: 'BOC Account',
        isPaid: true,
        paidDate: '2026-08-26',
      ),
      FixedPayment(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Commercial Bank Personal Loan',
        amount: 47544.0,
        dueDayOfMonth: 26,
        category: 'Loan',
        isPaid: true,
        paidDate: '2026-08-26',
      ),
      FixedPayment(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Gold Loan Interest (Bracelet & Rings)',
        amount: 8500.0,
        dueDayOfMonth: 26,
        category: 'Loan',
        isPaid: false,
      ),
    ];

    // Subscriptions
    _subscriptions = [
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Dialog Mobile',
        originalAmount: 2054.0,
        amountLkr: 2054.0,
        billingDay: 24,
        category: 'Telecom',
        isPaid: true,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Dialog Broadband Router',
        originalAmount: 5000.0,
        amountLkr: 5000.0,
        billingDay: 24,
        category: 'Telecom',
        isPaid: false,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Office Phone Loan',
        originalAmount: 4500.0,
        amountLkr: 4500.0,
        billingDay: 24,
        category: 'Telecom',
        isPaid: false,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Netflix Basic',
        originalCurrency: 'USD',
        originalAmount: 3.99,
        amountLkr: 1400.0,
        billingDay: 24,
        category: 'Entertainment',
        isPaid: true,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Apple Music',
        originalCurrency: 'USD',
        originalAmount: 3.29,
        amountLkr: 1080.0,
        billingDay: 26,
        category: 'Entertainment',
        isPaid: true,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'Apple iCloud',
        originalCurrency: 'USD',
        originalAmount: 2.99,
        amountLkr: 1000.0,
        billingDay: 26,
        category: 'Cloud',
        isPaid: true,
      ),
      Subscription(
        id: _uuid.v4(),
        householdId: _household.id,
        name: 'YouTube Premium',
        originalAmount: 1200.0,
        amountLkr: 1200.0,
        billingDay: 28,
        category: 'Entertainment',
        isPaid: false,
      ),
    ];

    // Credit Cards
    _creditCards = [
      CreditCard(
        id: _uuid.v4(),
        householdId: _household.id,
        bankName: 'Commercial Bank',
        cardName: 'Combank Platinum',
        statementAmount: 40000.0,
        minimumDue: 5000.0,
        dueDay: 26,
        isPaid: true,
        paidAmount: 40000.0,
      ),
      CreditCard(
        id: _uuid.v4(),
        householdId: _household.id,
        bankName: 'Sampath Bank',
        cardName: 'Sampath Signature',
        statementAmount: 5000.0,
        minimumDue: 2000.0,
        dueDay: 26,
        isPaid: true,
        paidAmount: 5000.0,
      ),
      CreditCard(
        id: _uuid.v4(),
        householdId: _household.id,
        bankName: 'DFCC',
        cardName: 'DFCC Visa',
        statementAmount: 0.0,
        minimumDue: 0.0,
        dueDay: 28,
        isPaid: true,
      ),
    ];

    // Installments
    _installmentPlans = [
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: wifeMember.id,
        platform: 'Koko',
        itemName: 'Dinapala Group (Water Filter)',
        totalAmount: 13647.0,
        monthlyInstallment: 4549.0,
        remainingBalance: 4549.0,
        totalInstallments: 3,
        installmentsPaid: 2,
        dueDayOfMonth: 27,
        startDate: now,
        isPaidInCurrentCycle: true,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: wifeMember.id,
        platform: 'Koko',
        itemName: 'Strong.lk (Supplements)',
        totalAmount: 14424.0,
        monthlyInstallment: 4808.0,
        remainingBalance: 4808.0,
        totalInstallments: 3,
        installmentsPaid: 2,
        dueDayOfMonth: 27,
        startDate: now,
        isPaidInCurrentCycle: true,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: wifeMember.id,
        platform: 'Koko',
        itemName: 'Dmart (Vacuum Cleaner)',
        totalAmount: 2850.0,
        monthlyInstallment: 950.0,
        remainingBalance: 950.0,
        totalInstallments: 3,
        installmentsPaid: 2,
        dueDayOfMonth: 7,
        startDate: now,
        isPaidInCurrentCycle: true,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: wifeMember.id,
        platform: 'Koko',
        itemName: 'Candy (Clothes)',
        totalAmount: 5316.0,
        monthlyInstallment: 1772.0,
        remainingBalance: 1772.0,
        totalInstallments: 3,
        installmentsPaid: 2,
        dueDayOfMonth: 2,
        startDate: now,
        isPaidInCurrentCycle: true,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: selfMember.id,
        platform: 'Koko',
        itemName: 'Sensara (Perfume)',
        totalAmount: 16131.0,
        monthlyInstallment: 5377.0,
        remainingBalance: 10754.0,
        totalInstallments: 3,
        installmentsPaid: 1,
        dueDayOfMonth: 29,
        startDate: now,
        isPaidInCurrentCycle: false,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: selfMember.id,
        platform: 'Koko',
        itemName: 'Deedat (Shirt)',
        totalAmount: 3990.0,
        monthlyInstallment: 1330.0,
        remainingBalance: 2660.0,
        totalInstallments: 3,
        installmentsPaid: 1,
        dueDayOfMonth: 29,
        startDate: now,
        isPaidInCurrentCycle: false,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: selfMember.id,
        platform: 'Mintpay',
        itemName: 'Online Kade (Groceries 1)',
        totalAmount: 16941.0,
        monthlyInstallment: 5647.0,
        remainingBalance: 5647.0,
        totalInstallments: 3,
        installmentsPaid: 2,
        dueDayOfMonth: 30,
        startDate: now,
        isPaidInCurrentCycle: true,
      ),
      InstallmentPlan(
        id: _uuid.v4(),
        householdId: _household.id,
        memberId: selfMember.id,
        platform: 'PayZy',
        itemName: 'Beauty Harbour (Cosmetics)',
        totalAmount: 16500.0,
        monthlyInstallment: 5500.0,
        remainingBalance: 11000.0,
        totalInstallments: 3,
        installmentsPaid: 1,
        dueDayOfMonth: 31,
        startDate: now,
        isPaidInCurrentCycle: false,
      ),
    ];

    // Wishlist
    _wishlistItems = [
      WishlistItem(
        id: _uuid.v4(),
        householdId: _household.id,
        itemName: 'Potato Smasher',
        category: 'Kitchen',
        estimatedCost: 800.0,
        priority: 'high',
        isPlannedForCurrentCycle: true,
      ),
      WishlistItem(
        id: _uuid.v4(),
        householdId: _household.id,
        itemName: 'Litro Gas Cylinder Refill',
        category: 'Kitchen',
        estimatedCost: 4200.0,
        priority: 'high',
        isPlannedForCurrentCycle: true,
      ),
      WishlistItem(
        id: _uuid.v4(),
        householdId: _household.id,
        itemName: 'Air Fryer / Convection Oven',
        category: 'Kitchen',
        estimatedCost: 38000.0,
        priority: 'medium',
        isPlannedForCurrentCycle: false,
      ),
      WishlistItem(
        id: _uuid.v4(),
        householdId: _household.id,
        itemName: 'New Bidet Shower Sprayer',
        category: 'Bathroom',
        estimatedCost: 2800.0,
        priority: 'high',
        isPlannedForCurrentCycle: true,
      ),
      WishlistItem(
        id: _uuid.v4(),
        householdId: _household.id,
        itemName: 'Floor Wiper',
        category: 'Bathroom',
        estimatedCost: 1100.0,
        priority: 'medium',
        isPlannedForCurrentCycle: true,
      ),
    ];

    // Daily Spends
    _dailySpends = [
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 25),
        amount: 200.0,
        category: 'Health & Gym',
        paymentMethod: 'Cash',
        title: 'Gym Pure Water',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 25),
        amount: 1400.0,
        category: 'Groceries',
        paymentMethod: 'Cash',
        title: 'Chicken 1.1kg',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 25),
        amount: 6802.0,
        category: 'Groceries',
        paymentMethod: 'Commercial Debit Card',
        title: 'Food City Supermarket Groceries',
        notes: 'Milk, cheese, soap, repellent',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 25),
        amount: 406.0,
        category: 'Transport / PickMe',
        paymentMethod: 'Cash',
        title: 'PickMe Tuk to Grocery',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 25),
        amount: 4100.0,
        category: 'Food & Dining',
        paymentMethod: 'Commercial Debit Card',
        title: 'Spar Supermarket Beverages',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 26),
        amount: 10000.0,
        category: 'Other / Cash Reserve',
        paymentMethod: 'Fund Transfer',
        title: 'Transfer to Wife Combank Account',
        notes: 'Monthly personal pocket allowance',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 26),
        amount: 4500.0,
        category: 'Other / Cash Reserve',
        paymentMethod: 'Cash',
        title: 'ATM Cash Withdrawal for Wallet',
      ),
      DailySpend(
        id: _uuid.v4(),
        householdId: _household.id,
        cycleId: _activeCycle!.id,
        date: DateTime(2026, 8, 26),
        amount: 520.0,
        category: 'Personal Care & Saloon',
        paymentMethod: 'Cash',
        title: 'Saloon Haircut & Grooming',
      ),
    ];

    refreshAiAdvice();
    notifyListeners();
  }

  void setSelectedMember(String memberId) {
    _selectedMemberId = memberId;
    notifyListeners();
  }

  // --- FULL ADMIN CMS CRUD ACTIONS ---

  // Members CMS
  void addMember(HouseholdMember member) {
    _members.add(member);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateMember(HouseholdMember member) {
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx != -1) {
      _members[idx] = member;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // Fixed Payments CMS
  void addFixedPayment(FixedPayment payment) {
    _fixedPayments.add(payment);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateFixedPayment(FixedPayment payment) {
    final idx = _fixedPayments.indexWhere((p) => p.id == payment.id);
    if (idx != -1) {
      _fixedPayments[idx] = payment;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteFixedPayment(String id) {
    _fixedPayments.removeWhere((p) => p.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // BNPL Installments CMS
  void addInstallmentPlan(InstallmentPlan plan) {
    _installmentPlans.add(plan);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateInstallmentPlan(InstallmentPlan plan) {
    final idx = _installmentPlans.indexWhere((p) => p.id == plan.id);
    if (idx != -1) {
      _installmentPlans[idx] = plan;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteInstallmentPlan(String id) {
    _installmentPlans.removeWhere((p) => p.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // Subscriptions CMS
  void addSubscription(Subscription sub) {
    _subscriptions.add(sub);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateSubscription(Subscription sub) {
    final idx = _subscriptions.indexWhere((s) => s.id == sub.id);
    if (idx != -1) {
      _subscriptions[idx] = sub;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // Credit Cards CMS
  void addCreditCard(CreditCard card) {
    _creditCards.add(card);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateCreditCard(CreditCard card) {
    final idx = _creditCards.indexWhere((c) => c.id == card.id);
    if (idx != -1) {
      _creditCards[idx] = card;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteCreditCard(String id) {
    _creditCards.removeWhere((c) => c.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // Wishlist CMS
  void addWishlistItem(WishlistItem item) {
    _wishlistItems.add(item);
    refreshAiAdvice();
    notifyListeners();
  }

  void updateWishlistItem(WishlistItem item) {
    final idx = _wishlistItems.indexWhere((w) => w.id == item.id);
    if (idx != -1) {
      _wishlistItems[idx] = item;
      refreshAiAdvice();
      notifyListeners();
    }
  }

  void deleteWishlistItem(String id) {
    _wishlistItems.removeWhere((w) => w.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  // System Config CMS
  void updateHouseholdSettings({required String name, required int cycleStartDay, required String currencySymbol, String? geminiKey}) {
    _household = _household.copyWith(
      name: name,
      cycleStartDay: cycleStartDay,
      currencySymbol: currencySymbol,
      geminiApiKey: geminiKey,
    );
    refreshAiAdvice();
    notifyListeners();
  }

  // Income & Daily Spend Actions
  void addIncomeEntry(IncomeEntry entry) {
    _incomeEntries.insert(0, entry);
    refreshAiAdvice();
    notifyListeners();
  }

  void deleteIncomeEntry(String id) {
    _incomeEntries.removeWhere((item) => item.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  void addDailySpend(DailySpend spend) {
    _dailySpends.insert(0, spend);
    refreshAiAdvice();
    notifyListeners();
  }

  void deleteDailySpend(String id) {
    _dailySpends.removeWhere((item) => item.id == id);
    refreshAiAdvice();
    notifyListeners();
  }

  void toggleFixedPaymentPaid(String id) {
    final index = _fixedPayments.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _fixedPayments[index];
      _fixedPayments[index] = current.copyWith(
        isPaid: !current.isPaid,
        paidDate: !current.isPaid ? DateTime.now().toString().split(' ')[0] : null,
      );
      notifyListeners();
    }
  }

  void toggleInstallmentPaid(String id) {
    final index = _installmentPlans.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _installmentPlans[index];
      _installmentPlans[index] = current.copyWith(
        isPaidInCurrentCycle: !current.isPaidInCurrentCycle,
      );
      notifyListeners();
    }
  }

  void toggleCreditCardPaid(String id) {
    final index = _creditCards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _creditCards[index];
      _creditCards[index] = current.copyWith(isPaid: !current.isPaid);
      notifyListeners();
    }
  }

  void toggleSubscriptionPaid(String id) {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final current = _subscriptions[index];
      _subscriptions[index] = current.copyWith(isPaid: !current.isPaid);
      notifyListeners();
    }
  }

  void toggleWishlistPlan(String id) {
    final index = _wishlistItems.indexWhere((w) => w.id == id);
    if (index != -1) {
      final current = _wishlistItems[index];
      _wishlistItems[index] = current.copyWith(
        isPlannedForCurrentCycle: !current.isPlannedForCurrentCycle,
      );
      refreshAiAdvice();
      notifyListeners();
    }
  }

  Future<void> refreshAiAdvice() async {
    if (_activeCycle == null) return;
    _isLoadingAdvice = true;
    notifyListeners();

    final advice = await AIAdvisorService.generateCycleAdvice(
      currentMetrics: currentMetrics,
      nextForecast: nextForecast,
      activeCycle: _activeCycle!,
      currencySymbol: _household.currencySymbol,
      apiKey: _household.geminiApiKey,
    );

    _aiAdvice = advice;
    _isLoadingAdvice = false;
    notifyListeners();
  }

  void updateGeminiApiKey(String key) {
    _household = _household.copyWith(geminiApiKey: key);
    refreshAiAdvice();
    notifyListeners();
  }
}
