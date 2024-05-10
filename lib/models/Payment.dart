class Payment {
  final String id;
  final double amount;
  final String currency;
  final String country;
  final DateTime createdDate;
  final String status;
  final String orderId;
  final String redirectUrl;
  final String merchantCheckoutToken;
  final bool direct;

  Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.country,
    required this.createdDate,
    required this.status,
    required this.orderId,
    required this.redirectUrl,
    required this.merchantCheckoutToken,
    required this.direct,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      currency: json['currency'],
      country: json['country'],
      createdDate: DateTime.parse(json['created_date']),
      status: json['status'],
      orderId: json['order_id'],
      redirectUrl: json['redirect_url'],
      merchantCheckoutToken: json['merchant_checkout_token'],
      direct: json['direct'],
    );
  }
}
