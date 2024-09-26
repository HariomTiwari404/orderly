import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final String imagePath;
  final int quantity;
  final double unitValue;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final DateTime lastUpdated;
  final int inventoryId;
  final List<SaleRecord> salesHistory;
  final List<InvestmentRecord> investmentHistory;

  Product({
    this.id,
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.unitValue,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.lastUpdated,
    required this.inventoryId,
    this.salesHistory = const [],
    this.investmentHistory = const [],
  });

  Product copyWith({
    int? id,
    String? name,
    String? imagePath,
    int? quantity,
    double? unitValue,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    DateTime? lastUpdated,
    int? inventoryId,
    List<SaleRecord>? salesHistory,
    List<InvestmentRecord>? investmentHistory,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      unitValue: unitValue ?? this.unitValue,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      inventoryId: inventoryId ?? this.inventoryId,
      salesHistory: salesHistory ?? this.salesHistory,
      investmentHistory: investmentHistory ?? this.investmentHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'quantity': quantity,
      'unitValue': unitValue,
      'unit': unit,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
      'inventoryId': inventoryId,
      'salesHistory':
          jsonEncode(salesHistory.map((sale) => sale.toMap()).toList()),
      'investmentHistory':
          jsonEncode(investmentHistory.map((inv) => inv.toMap()).toList()),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      quantity: map['quantity'],
      unitValue: map['unitValue'],
      unit: map['unit'],
      costPrice: map['costPrice'],
      sellingPrice: map['sellingPrice'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
      inventoryId: map['inventoryId'],
      salesHistory: List<SaleRecord>.from(jsonDecode(map['salesHistory'])
          .map((sale) => SaleRecord.fromMap(sale))),
      investmentHistory: List<InvestmentRecord>.from(
          jsonDecode(map['investmentHistory'])
              .map((inv) => InvestmentRecord.fromMap(inv))),
    );
  }
}

class SaleRecord {
  final DateTime date;
  final int quantitySold;
  final double sellingPrice;

  SaleRecord({
    required this.date,
    required this.quantitySold,
    required this.sellingPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'quantitySold': quantitySold,
      'sellingPrice': sellingPrice,
    };
  }

  factory SaleRecord.fromMap(Map<String, dynamic> map) {
    return SaleRecord(
      date: DateTime.parse(map['date']),
      quantitySold: map['quantitySold'],
      sellingPrice: map['sellingPrice'],
    );
  }
}

class InvestmentRecord {
  final DateTime date;
  final double amount;

  InvestmentRecord({
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  factory InvestmentRecord.fromMap(Map<String, dynamic> map) {
    return InvestmentRecord(
      date: DateTime.parse(map['date']),
      amount: map['amount'],
    );
  }
}
