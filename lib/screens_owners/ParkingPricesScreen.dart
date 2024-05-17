import 'package:flutter/material.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/services/api_type_price_service.dart'; // Importa correctamente el servicio
import 'package:map_flutter/common/widgets/cards/PriceCard.dart';

class ParkingPricesScreen extends StatefulWidget {
  final String parkingId;

  const ParkingPricesScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _ParkingPricesScreenState createState() => _ParkingPricesScreenState();
}

class _ParkingPricesScreenState extends State<ParkingPricesScreen> {
  Future<List<Price>>? prices;

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    try {
      TypePriceService typePriceService = TypePriceService();
      prices = typePriceService.getAllPriceRecords(int.parse(widget.parkingId));
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Precios del Parqueo'),
      ),
      body: FutureBuilder<List<Price>>(
        future: prices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron precios.'));
          } else {
            List<Price> prices = snapshot.data!;
            return ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                Price price = prices[index];
                return PriceCard(price: price);
              },
            );
          }
        },
      ),
    );
  }
}
