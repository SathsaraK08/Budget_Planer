class ForecastSettings {
  final int survivalBufferDays;
  final double reservePercentage; // e.g. 5.0 for 5%
  final List<String> committedCategories;

  const ForecastSettings({
    this.survivalBufferDays = 30,
    this.reservePercentage = 5.0,
    this.committedCategories = const ['Housing', 'Utilities', 'Loan', 'Insurance', 'Telecom'],
  });

  factory ForecastSettings.fromJson(Map<String, dynamic> json) {
    return ForecastSettings(
      survivalBufferDays: (json['survival_buffer_days'] as num?)?.toInt() ?? 30,
      reservePercentage: (json['reserve_percentage'] as num?)?.toDouble() ?? 5.0,
      committedCategories: (json['committed_categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Housing', 'Utilities', 'Loan', 'Insurance', 'Telecom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'survival_buffer_days': survivalBufferDays,
      'reserve_percentage': reservePercentage,
      'committed_categories': committedCategories,
    };
  }

  ForecastSettings copyWith({
    int? survivalBufferDays,
    double? reservePercentage,
    List<String>? committedCategories,
  }) {
    return ForecastSettings(
      survivalBufferDays: survivalBufferDays ?? this.survivalBufferDays,
      reservePercentage: reservePercentage ?? this.reservePercentage,
      committedCategories: committedCategories ?? this.committedCategories,
    );
  }
}
