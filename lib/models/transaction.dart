class Transaction {
  final int? id;
  final int khataId;
  final int productId;
  final double amountPaid;
  final double remainingAmount;
  final String transactionDate;
  final bool isCredit;

  Transaction({
    this.id,
    required this.khataId,
    required this.productId,
    required this.amountPaid,
    required this.remainingAmount,
    required this.transactionDate,
    required this.isCredit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'khataId': khataId,
      'productId': productId,
      'amountPaid': amountPaid,
      'remainingAmount': remainingAmount,
      'transactionDate': transactionDate,
      'isCredit': isCredit ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      khataId: map['khataId'],
      productId: map['productId'],
      amountPaid: map['amountPaid'],
      remainingAmount: map['remainingAmount'],
      transactionDate: map['transactionDate'],
      isCredit: map['isCredit'] == 1,
    );
  }
}
