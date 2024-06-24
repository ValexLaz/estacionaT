import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/widgets/cards/PriceCard.dart';
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/screens_users/parkingDetails/reservationForm.dart';
import 'package:map_flutter/screens_users/routes_screen.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_price.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_flutter/services/distance_service.dart';

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
  LatLng? userLocation;

  @override
  void initState() {
    ParkingManager.instance
        .setParking(Parking(id: int.parse(widget.parkingId), name: "parqueo"));
    super.initState();
    _determinePosition().then((_) => fetchParkingData());
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
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
      if (userLocation != null) {
        await DistanceService.calculateRoutesForAllParkings(
            [parkingDetails], userLocation!);
      }
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
          title: Text(
            'Detalles del parqueo',
            style: TextStyle(color: Colors.black,),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: buildParkingImage(),
                  ),
                  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parkingDetails['name'] ?? '',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.black54,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    parkingDetails['street'] ?? 'Dirección no disponible',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingMapScreen(
                    parkingId: widget.parkingId,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.near_me,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ),
    ],
  ),
),
                  Container(
                    child: Material(
                      color: Colors.white,
                      child: TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.blueAccent,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info),
                            text: "Información",
                          ),
                          Tab(
                            icon: Icon(Icons.schedule),
                            text: "Horarios",
                          ),
                          Tab(
                            icon: Icon(Icons.attach_money),
                            text: "Precios",
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildContactAndMoreTab(),
                        buildScheduleTab(),
                        buildPricesTab(),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildParkingImage() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: (parkingDetails['url_image'] != null &&
              parkingDetails['url_image'].isNotEmpty)
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
        // Ordenar los horarios de lunes a domingo sin tildes
        openingHours.sort((a, b) {
          final daysOfWeek = [
            'Lunes',
            'Martes',
            'Miercoles',
            'Jueves',
            'Viernes',
            'Sabado',
            'Domingo'
          ];
          return daysOfWeek.indexOf(a.day ?? '') -
              daysOfWeek.indexOf(b.day ?? '');
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_filled, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Horarios de Atencion',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: openingHours.map((hour) {
                  String openTime = formatTime(hour.open_time);
                  String closeTime = formatTime(hour.close_time);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            hour.day ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('$openTime - $closeTime',
                              style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }
    },
  );
}

String formatTime(String? time) {
  if (time == null || time.isEmpty) return '';
  final timeParts = time.split(':');
  if (timeParts.length >= 2) {
    int hour = int.parse(timeParts[0]);
    String period = hour >= 12 ? 'p.m.' : 'a.m.';
    hour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '${hour}:${timeParts[1]} $period';
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
              return PriceCard(
                price: price,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ReservationFormScreen(
                        price: snapshot.data![index],
                      ),
                    ),
                  );
                },
              );
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${parkingDetails['spaces_available'] ?? 'N/A'} espacios disponibles',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        if (parkingDetails.containsKey('distance') &&
            parkingDetails.containsKey('eta'))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.timer,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tiempo estimado: ${parkingDetails['eta']}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Distancia: ${parkingDetails['distance']}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 8.0),
          child: Text(
            'Descripción',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (parkingDetails['description'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              parkingDetails['description'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 8.0),
          child: Text(
            'Contacto',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (parkingDetails['phone'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => launchPhoneDialer(parkingDetails['phone']),
                  icon: Icon(Icons.phone, color: Colors.blue),
                  label: Text('Llamar', style: TextStyle(color: Colors.blue)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => launchWhatsApp(parkingDetails['phone']),
                  icon: Icon(Icons.message, color: Colors.blue),
                  label: Text('WhatsApp', style: TextStyle(color: Colors.blue)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

}
