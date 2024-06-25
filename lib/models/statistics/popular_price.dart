class PopularPrices {
  final List<PriceInfo> popularReservationPrices;
  final List<PriceInfo> popularDetailsPrices;
  final String filter;

  PopularPrices({
    required this.popularReservationPrices,
    required this.popularDetailsPrices,
    required this.filter,
  });

  factory PopularPrices.fromJson(Map<String, dynamic> json) {
    return PopularPrices(
      popularReservationPrices: (json['popular_reservation_prices'] as List)
          .map((price) => PriceInfo.fromJson(price))
          .toList(),
      popularDetailsPrices: (json['popular_details_prices'] as List)
          .map((price) => PriceInfo.fromJson(price))
          .toList(),
      filter: json['filter'],
    );
  }
}

class PriceInfo {
  final int priceId;
  final double price;
  final String typeVehicleName;
  final int count;

  PriceInfo({
    required this.priceId,
    required this.price,
    required this.typeVehicleName,
    required this.count,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      priceId: json['price__id'],
      price: json['price__price'].toDouble(),
      typeVehicleName: json['price__type_vehicle__name'],
      count: json['count'],
    );
  }
}