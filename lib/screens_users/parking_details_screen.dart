import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';

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
  String? selectedRate;
  List<String> rates = ['5 Bs', '10 Bs', '15 Bs'];

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
                    Image.network(
                      'https://www.prensalibre.com/wp-content/uploads/2019/01/033aaf7c-54ac-4004-bdf2-8106856fa992.jpg?quality=52',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4,
                      fit: BoxFit.cover,
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
                            IconButton(
                              icon: Icon(Icons.message, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContactScreen(
                                      phone: parkingDetails['phone'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ubicación: ${parkingDetails['location'] ?? 'Seg. Anillo Av. Banzer'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Descripción:',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          parkingDetails['description'] ??
                              'Descripción no disponible',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Espacios Disponibles: ${parkingDetails['spaces_available'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
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
                  child: DropdownButton<String>(
                    value: selectedRate,
                    hint: const Text('Selecciona Tarifa'),
                    items: rates.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRate = newValue;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.all(2.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Cancelar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: Size(
                                150, 50), // Increase the size of the button
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Reservar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1b4ee4),
                          foregroundColor: Colors.white,
                          minimumSize:
                              Size(150, 50), // Increase the size of the button
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

class ContactScreen extends StatelessWidget {
  final String? phone;

  const ContactScreen({Key? key, this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacto'),
      ),
      body: Center(
        child: Text(
          'Teléfono: $phone',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
