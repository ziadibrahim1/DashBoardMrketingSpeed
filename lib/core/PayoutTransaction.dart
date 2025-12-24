class PayoutTransaction {
  final double paidAmount;
  final int paidPoints;
  final String paymentMethod;
  final String referenceNumber;
  final DateTime paidAt;

  PayoutTransaction({
    required this.paidAmount,
    required this.paidPoints,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.paidAt,
  });

  factory PayoutTransaction.fromJson(Map<String, dynamic> json) {
    return PayoutTransaction(
      paidAmount: (json['paidAmount'] as num).toDouble(),
      paidPoints: json['paidPoints'],
      paymentMethod: json['paymentMethod'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      paidAt: DateTime.parse(json['paidAt']),
    );
  }
}
