import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/widgets/cards/PriceCard.dart';
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/models/Price.dart';
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

  Future<void> openMapWithDestination() async {
    final double? latitude = parkingDetails['latitude'] != null
        ? double.tryParse(parkingDetails['latitude'].toString())
        : null;
    final double? longitude = parkingDetails['longitude'] != null
        ? double.tryParse(parkingDetails['longitude'].toString())
        : null;

    if (latitude != null && longitude != null) {
      // Utilizando el esquema de URL específico para abrir la aplicación de Google Maps
      final Uri googleMapUrl =
          Uri.parse("google.navigation:q=$latitude,$longitude&mode=d");

      if (await canLaunchUrl(googleMapUrl)) {
        await launchUrl(googleMapUrl);
      } else {
        // Si Google Maps no está disponible, intenta abrir en el navegador
        final Uri fallbackUrl = Uri.parse(
            "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving");
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir Google Maps.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontraron datos de ubicación válidos.'),
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
        body: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
              ),
              items: [
                'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
                'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
                'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
                'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Image.network(i, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
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
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blue),
                  title: Text(
                    hour.day ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${hour.open_time} - ${hour.close_time}'),
                ),
              );
            },
          );
        }
      },
    );
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
              return PriceCard(price: price);
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
          if (parkingDetails['phone'] != null)
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Teléfono:'),
              subtitle: Text(parkingDetails['phone']),
              onTap: () => launchPhoneDialer(parkingDetails['phone']),
            ),
          if (parkingDetails['whatsapp'] != null)
            ListTile(
              //leading: Icon(Icons.whatsapp),
              title: Text('WhatsApp:'),
              subtitle: Text(parkingDetails['whatsapp']),
              onTap: () => launchWhatsApp(parkingDetails['whatsapp']),
            ),
          if (parkingDetails['address'] != null)
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Dirección:'),
              subtitle: Text(parkingDetails['address']),
            ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Abrir en Google Maps'),
            onTap: openMapWithDestination,
          ),
        ],
      ),
    );
  }
}
