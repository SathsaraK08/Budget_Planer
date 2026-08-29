class HouseholdMember {
  final String id;
  final String householdId;
  final String? userId;
  final String name;
  final String role; // 'husband', 'wife', 'self', 'partner'
  final String avatarColor;
  final double regularMonthlySalary;

  HouseholdMember({
    required this.id,
    required this.householdId,
    this.userId,
    required this.name,
    this.role = 'member',
    this.avatarColor = '#10B981',
    this.regularMonthlySalary = 0.0,
  });

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? 'Member',
      role: json['role'] as String? ?? 'member',
      avatarColor: json['avatar_color'] as String? ?? '#10B981',
      regularMonthlySalary: (json['regular_monthly_salary'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'user_id': userId,
      'name': name,
      'role': role,
      'avatar_color': avatarColor,
      'regular_monthly_salary': regularMonthlySalary,
    };
  }

  HouseholdMember copyWith({
    String? id,
    String? householdId,
    String? userId,
    String? name,
    String? role,
    String? avatarColor,
    double? regularMonthlySalary,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarColor: avatarColor ?? this.avatarColor,
      regularMonthlySalary: regularMonthlySalary ?? this.regularMonthlySalary,
    );
  }
}
