class WishlistItem {
  final String id;
  final String householdId;
  final String? plannedCycleId;
  final String itemName;
  final String category; // 'Kitchen', 'Bathroom', 'Cosmetics & Beauty', 'Other'
  final double estimatedCost;
  final String priority; // 'high', 'medium', 'low'
  final bool isPurchased;
  final bool isPlannedForCurrentCycle;
  final String? purchasedDate;
  final double? actualCost;
  final String? notes;

  WishlistItem({
    required this.id,
    required this.householdId,
    this.plannedCycleId,
    required this.itemName,
    this.category = 'Kitchen',
    this.estimatedCost = 0.0,
    this.priority = 'medium',
    this.isPurchased = false,
    this.isPlannedForCurrentCycle = false,
    this.purchasedDate,
    this.actualCost,
    this.notes,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      plannedCycleId: json['planned_cycle_id'] as String?,
      itemName: json['item_name'] as String? ?? 'Item',
      category: json['category'] as String? ?? 'Kitchen',
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] as String? ?? 'medium',
      isPurchased: json['is_purchased'] as bool? ?? false,
      isPlannedForCurrentCycle: json['is_planned_for_current_cycle'] as bool? ?? false,
      purchasedDate: json['purchased_date'] as String?,
      actualCost: (json['actual_cost'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      if (plannedCycleId != null) 'planned_cycle_id': plannedCycleId,
      'item_name': itemName,
      'category': category,
      'estimated_cost': estimatedCost,
      'priority': priority,
      'is_purchased': isPurchased,
      'is_planned_for_current_cycle': isPlannedForCurrentCycle,
      if (purchasedDate != null) 'purchased_date': purchasedDate,
      if (actualCost != null) 'actual_cost': actualCost,
      if (notes != null) 'notes': notes,
    };
  }

  WishlistItem copyWith({
    String? id,
    String? householdId,
    String? plannedCycleId,
    String? itemName,
    String? category,
    double? estimatedCost,
    String? priority,
    bool? isPurchased,
    bool? isPlannedForCurrentCycle,
    String? purchasedDate,
    double? actualCost,
    String? notes,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      plannedCycleId: plannedCycleId ?? this.plannedCycleId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      priority: priority ?? this.priority,
      isPurchased: isPurchased ?? this.isPurchased,
      isPlannedForCurrentCycle: isPlannedForCurrentCycle ?? this.isPlannedForCurrentCycle,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      actualCost: actualCost ?? this.actualCost,
      notes: notes ?? this.notes,
    );
  }
}
