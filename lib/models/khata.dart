class Khata {
  final int? id;
  final int customerId;
  final DateTime startDate;
  final DateTime paymentDueDate;
  final double totalAmount;
  final double remainingAmount;

  Khata({
    this.id,
    required this.customerId,
    required this.startDate,
    required this.paymentDueDate,
    required this.totalAmount,
    required this.remainingAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'startDate': startDate.toIso8601String(),
      'paymentDueDate': paymentDueDate.toIso8601String(),
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
    };
  }

  factory Khata.fromMap(Map<String, dynamic> map) {
    return Khata(
      id: map['id'],
      customerId: map['customerId'],
      startDate: DateTime.parse(map['startDate']),
      paymentDueDate: DateTime.parse(map['paymentDueDate']),
      totalAmount: map['totalAmount'],
      remainingAmount: map['remainingAmount'],
    );
  }
}
