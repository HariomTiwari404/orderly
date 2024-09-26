class Credit {
  final int? id;
  final String name;
  final String phoneNumber;
  final double amount;
  final bool
      isGiven; // true if the money is to be given, false if it's to be received
  final DateTime paymentDateTime;

  Credit({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.amount,
    required this.isGiven,
    required this.paymentDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'isGiven': isGiven ? 1 : 0,
      'paymentDateTime': paymentDateTime.toIso8601String(),
    };
  }

  static Credit fromMap(Map<String, dynamic> map) {
    return Credit(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      amount: map['amount'],
      isGiven: map['isGiven'] == 1,
      paymentDateTime: DateTime.parse(map['paymentDateTime']),
    );
  }
}
