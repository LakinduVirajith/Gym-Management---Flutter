class PaymentDetails {
  final double amount;
  final String accountNumber;

  PaymentDetails({required this.amount, required this.accountNumber});

  // Factory method to create a Payment object from a JSON map
  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      amount: json['amount'],
      accountNumber: json['account_number'],
    );
  }
}
