class Household {
  final String id;
  final String name;
  final String currencySymbol; // e.g. 'Rs.'
  final String currencyCode;   // e.g. 'LKR'
  final int cycleStartDay;
  final String? geminiApiKey;
  /// True once the first-run setup wizard has been completed.
  /// Stored in the DB as `households.setup_completed` — NOT client-only.
  final bool setupCompleted;
  final String appName;

  Household({
    required this.id,
    required this.name,
    this.currencySymbol = 'Rs.',
    this.currencyCode = 'LKR',
    this.cycleStartDay = 25,
    this.geminiApiKey,
    this.setupCompleted = false,
    this.appName = 'HomeBudget',
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Our Household',
      currencySymbol: json['currency_symbol'] as String? ?? 'Rs.',
      currencyCode: json['currency_code'] as String? ?? 'LKR',
      cycleStartDay: (json['cycle_start_day'] as num?)?.toInt() ?? 25,
      geminiApiKey: json['gemini_api_key'] as String?,
      setupCompleted: json['setup_completed'] as bool? ?? false,
      appName: json['app_name'] as String? ?? 'HomeBudget',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
      'cycle_start_day': cycleStartDay,
      'setup_completed': setupCompleted,
      'app_name': appName,
      if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
    };
  }

  Household copyWith({
    String? id,
    String? name,
    String? currencySymbol,
    String? currencyCode,
    int? cycleStartDay,
    String? geminiApiKey,
    bool? setupCompleted,
    String? appName,
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      setupCompleted: setupCompleted ?? this.setupCompleted,
      appName: appName ?? this.appName,
    );
  }
}
