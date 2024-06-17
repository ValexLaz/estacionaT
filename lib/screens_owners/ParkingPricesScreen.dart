import 'package:flutter/material.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/screens_owners/map_next.dart';
import 'package:map_flutter/services/api_type_price_service.dart'; // Importa correctamente el servicio
import 'package:map_flutter/common/widgets/cards/PriceCard.dart';
import 'package:map_flutter/screens_owners/price_screen.dart';

class ParkingPricesScreen extends StatefulWidget {
  final String parkingId;

  const ParkingPricesScreen({Key? key, required this.parkingId})
      : super(key: key);

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
      List<Price> fetchedPrices = await typePriceService.getAllPriceRecords(int.parse(widget.parkingId));
      setState(() {
        prices = Future.value(fetchedPrices);
      });
    } catch (e) {
      print('Error fetching prices: $e');
      setState(() {
        prices = Future.error('Error fetching prices: $e');
      });
    }
  }

  Future<void> deletePrice(int? priceId) async {
    if (priceId == null) {
      print('Error: priceId es null');
      return;
    }
    try {
      TypePriceService typePriceService = TypePriceService();
      await typePriceService.deletePriceRecord(priceId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Precio eliminado exitosamente')),
      );
      await fetchPrices();
    } catch (e) {
      print('Error deleting price: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el precio: $e')),
      );
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
            return Center(child: Text('No tienes precios registrados.'));
          } else {
            List<Price> prices = snapshot.data!;
            return ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                Price price = prices[index];
                return PriceCard(
                  price: price,
                  onDelete: () {
                    if (price.id != null) {
                      deletePrice(price.id); // Pasar el callback de eliminación
                    } else {
                      print('Error: El precio no tiene un ID válido');
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{
 Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PriceFormScreen(),
                        ),
                      )
        },
        child: Icon(Icons.add),
        tooltip: 'Registrar horario',
      ),
    );
  }
}
