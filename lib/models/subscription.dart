import 'dart:convert';

enum BillingCycle { monthly, yearly }

class Subscription {
  final String id;
  final String name;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final String category;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  const Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.category,
    this.isActive = true,
    this.notes,
    required this.createdAt,
  });

  double get monthlyCost =>
      billingCycle == BillingCycle.monthly ? cost : cost / 12;

  double get yearlyCost =>
      billingCycle == BillingCycle.yearly ? cost : cost * 12;

  int get daysUntilBilling {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final billing = DateTime(
      nextBillingDate.year,
      nextBillingDate.month,
      nextBillingDate.day,
    );
    return billing.difference(today).inDays;
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? cost,
    String? currency,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    String? category,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'cost': cost,
    'currency': currency,
    'billingCycle': billingCycle.name,
    'nextBillingDate': nextBillingDate.toIso8601String(),
    'category': category,
    'isActive': isActive,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Subscription.fromMap(Map<String, dynamic> map) => Subscription(
    id: map['id'] as String,
    name: map['name'] as String,
    cost: (map['cost'] as num).toDouble(),
    currency: map['currency'] as String,
    billingCycle: BillingCycle.values.firstWhere(
      (e) => e.name == map['billingCycle'],
      orElse: () => BillingCycle.monthly,
    ),
    nextBillingDate: DateTime.parse(map['nextBillingDate'] as String),
    category: map['category'] as String,
    isActive: map['isActive'] as bool? ?? true,
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  String toJson() => json.encode(toMap());

  factory Subscription.fromJson(String source) =>
      Subscription.fromMap(json.decode(source) as Map<String, dynamic>);
}
