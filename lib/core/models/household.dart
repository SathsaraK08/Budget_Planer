class Household {
  final String id;
  final String name;
  final String currencySymbol;
  final String currencyCode;
  final int cycleStartDay;
  final String? geminiApiKey;

  Household({
    required this.id,
    required this.name,
    this.currencySymbol = 'Rs.',
    this.currencyCode = 'LKR',
    this.cycleStartDay = 25,
    this.geminiApiKey,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Our Household',
      currencySymbol: json['currency_code'] as String? ?? 'Rs.',
      currencyCode: json['currency_symbol'] as String? ?? 'LKR',
      cycleStartDay: (json['cycle_start_day'] as num?)?.toInt() ?? 25,
      geminiApiKey: json['gemini_api_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency_code': currencySymbol,
      'currency_symbol': currencyCode,
      'cycle_start_day': cycleStartDay,
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
  }) {
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}
