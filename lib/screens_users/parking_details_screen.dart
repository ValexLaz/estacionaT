import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final String parkingId;

  const ParkingDetailsScreen({Key? key, required this.parkingId})
      : super(key: key);

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  final ApiParking apiParking = ApiParking();
  Map<String, dynamic> parkingDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParkingDetails();
  }

  Future<void> fetchParkingDetails() async {
    try {
      Map<String, dynamic> parkingDetail =
          await apiParking.getParkingDetailsById(widget.parkingId);
      setState(() {
        parkingDetails = parkingDetail;
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
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      child: Image.network(
                        'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                parkingDetails['name'] ?? 'Parking Name',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.blue),
                            Text(
                              '${parkingDetails['location'] ?? 'Seg. Anillo Av. Banzer'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Spacer(),
                            Text('Abierto',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.green)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          parkingDetails['description'] ??
                              'Descripción no disponible',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {}, // Add navigation logic here
                                icon: Icon(Icons.map),
                                label: Text('Dirección'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1b4ee4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFF1b4ee4)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (parkingDetails['phone'] != null) {
                                    launchPhoneDialer(parkingDetails['phone']);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Número de teléfono no disponible.'),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.call),
                                label: Text('Llamar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1b4ee4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFF1b4ee4)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (parkingDetails['phone'] != null) {
                                    launchWhatsApp(parkingDetails['phone']);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Número de teléfono no disponible.'),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.message),
                                label: Text('Mensaje'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1b4ee4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFF1b4ee4)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {}, // Add share logic here
                                icon: Icon(Icons.share),
                                label: Text('Compartir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF1b4ee4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Color(0xFF1b4ee4)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Espacios Disponibles:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${parkingDetails['spaces_available'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Capacidad Total:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${parkingDetails['capacity'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horarios',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Lunes:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Martes:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Miércoles:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Jueves:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Viernes:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Sábado:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 8.0),
                                Text(
                                  '6:00 AM - 10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '6:00 AM - 10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '6:00 AM - 10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '6:00 AM - 10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '6:00 AM - 10:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '8:00 AM - 9:00 PM',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Color(0xFF1b4ee4), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Tarifa',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1b4ee4),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '10:00 Bs/Por Hr.',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFF1b4ee4),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...parkingDetails.entries
                            .where((entry) => ![
                                  'name',
                                  'location',
                                  'description',
                                  'spaces_available',
                                  'id',
                                  'capacity',
                                  'email',
                                  'user',
                                  'url_image',
                                  'phone'
                                ].contains(entry.key))
                            .map((entry) => Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(fontSize: 16.0),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF1b4ee4),
                          minimumSize: Size(150, 50),
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Increase the border radius for a more rounded button
                            side: BorderSide(color: Color(0xFF1b4ee4)),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Reservar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1b4ee4),
                          foregroundColor: Colors.white,
                          minimumSize: Size(150, 50),
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Increase the border radius for a more rounded button
                            side: BorderSide(color: Color(0xFF1b4ee4)),
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
