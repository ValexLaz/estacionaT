import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/widgets/cards/PriceCard.dart';
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/screens_users/parkingDetails/reservationForm.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_price.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsScreen2 extends StatefulWidget {
  final String parkingId;

  const ParkingDetailsScreen2({Key? key, required this.parkingId})
      : super(key: key);

  @override
  State<ParkingDetailsScreen2> createState() => _ParkingDetailsScreen2State();
}

class _ParkingDetailsScreen2State extends State<ParkingDetailsScreen2> {
  final ApiParking apiParking = ApiParking();
  Map<String, dynamic> parkingDetails = {};
  bool isLoading = true;
  Future<List<Price>>? prices;
  Future<List<OpeningHours>>? openingHours;

  @override
  void initState() {
    ParkingManager.instance
        .setParking(Parking(id: int.parse(widget.parkingId), name: "parqueo"));
    super.initState();
    fetchParkingData();
  }

  Future<void> fetchPriceparking() async {
    try {
      ApiPrice apiPrice = ApiPrice();
      prices = apiPrice.getAllByParam('parking/${widget.parkingId}/');
    } catch (e) {}
  }

  Future<void> fetchOpeningHours() async {
    try {
      openingHours = ApiOpeningHours()
          .getOpeningHoursByParkingId(int.parse(widget.parkingId));
    } catch (e) {}
  }

  Future<void> fetchParkingData() async {
    try {
      await Future.wait([
        fetchParkingDetails(),
        fetchParkingAddress(),
        fetchPriceparking(),
        fetchOpeningHours()
      ]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking data: $e');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los datos del parqueo.')),
        );
      });
    }
  }

  Future<void> fetchParkingAddress() async {
    try {
      Map<String, dynamic> addressDetails =
          await apiParking.getParkingAddressById(widget.parkingId);
      if (addressDetails.isNotEmpty) {
        setState(() {
          parkingDetails.addAll(addressDetails);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontraron detalles de la dirección.'),
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    } catch (e) {
      print('Error fetching parking address details: $e');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los detalles de la dirección.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Future<void> fetchParkingDetails() async {
    try {
      Map<String, dynamic> parkingDetail =
          await apiParking.getParkingDetailsById(widget.parkingId);
      setState(() {
        parkingDetails.addAll(parkingDetail);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> launchWhatsApp(String phoneNumber) async {
    String message = Uri.encodeFull(
        "Hola, estoy interesado en más información sobre el parqueo.");

    final Uri uri = Uri.parse("https://wa.me/$phoneNumber?text=$message");

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No se pudo abrir WhatsApp. Asegúrese de que la app esté instalada.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> launchPhoneDialer(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No se pudo abrir el marcador telefónico. Asegúrese de que su dispositivo pueda hacer llamadas.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detalles del Parqueo'),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    child: buildParkingImage(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: 20,
                        top: 5), // Ajusta el valor del margen según tus necesidades
                    child: Material(
                      color: Colors.blue,
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,

                        // Color del indicador si deseas agregar

                        tabs: [
                          Tab(text: "Horarios"),
                          Tab(text: "Precios"),
                          Tab(text: "Contacto y Más"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildScheduleTab(),
                        buildPricesTab(),
                        buildContactAndMoreTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildParkingImage() {
    return (parkingDetails['url_image'] != null && parkingDetails['url_image'].isNotEmpty)
        ? Image.network(
            parkingDetails['url_image'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            'assets/images/Logo.png',
            fit: BoxFit.cover,
          );
  }

  Widget buildScheduleTab() {
    return FutureBuilder<List<OpeningHours>>(
      future: openingHours,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron horarios.'));
        } else {
          List<OpeningHours> openingHours = snapshot.data!;
          return ListView.builder(
            itemCount: openingHours.length,
            itemBuilder: (context, index) {
              OpeningHours hour = openingHours[index];
              String openTime = formatTime(hour.open_time);
              String closeTime = formatTime(hour.close_time);
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blue),
                  title: Text(
                    hour.day ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$openTime - $closeTime'),
                ),
              );
            },
          );
        }
      },
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return time;
  }

  Widget buildPricesTab() {
    return FutureBuilder<List<Price>>(
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
              return PriceCard(price: price,onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ReservationFormScreen(
                          price: snapshot.data![index],
                        ),
                      ));
                },);
            },
          );
        }
      },
    );
  }

  Widget buildContactAndMoreTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parkingDetails['name'] != null)
            ListTile(
              title: Text('Nombre del parqueo:'),
              subtitle: Text(parkingDetails['name']),
            ),
          if (parkingDetails['description'] != null)
            ListTile(
              title: Text('Descripción:'),
              subtitle: Text(parkingDetails['description']),
            ),
          if (parkingDetails['available_spaces'] != null)
            ListTile(
              title: Text('Espacios disponibles:'),
              subtitle: Text(parkingDetails['available_spaces'].toString()),
            ),
          if (parkingDetails['whatsapp'] != null)
            ListTile(
              title: Text('WhatsApp:'),
              subtitle: Text(parkingDetails['whatsapp']),
              onTap: () => launchWhatsApp(parkingDetails['whatsapp']),
            ),
        ],
      ),
    );
  }
}
