import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/screens_owners/create_account_owner.dart';
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';

class ListParkings extends StatefulWidget {
  const ListParkings({Key? key}) : super(key: key);

  @override
  State<ListParkings> createState() => _ListParkingsState();
}

class _ListParkingsState extends State<ListParkings> {
  final ApiParking apiParking = ApiParking();
  List<Map<String, dynamic>> parqueos = [];
  List<Map<String, dynamic>> addresses = [];
  Color primaryColor = Color(0xFF4285f4);
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? authToken = Provider.of<TokenProvider>(context, listen: false).token;
    fetchData(authToken);
  }

  Future<void> fetchData(String? token) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      List<Map<String, dynamic>> data = await apiParking.getParkingsByUserId(token!);
      List<Map<String, dynamic>> addressData = await apiParking.getAllParkingAddresses();

      data = data.map((parking) {
        var address = addressData.firstWhere(
            (addr) => addr['parking'] == parking['id'], orElse: () => {});
        parking['street'] = address['street']?.isNotEmpty == true
            ? address['street']
            : 'Ubicación no disponible';
        return parking;
      }).toList();

      if (!mounted) return;
      setState(() {
        parqueos = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener datos de parqueos: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteParking(String parkingId) async {
    try {
      await apiParking.deleteParkingById(parkingId);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: 'Éxito',
            message: 'Parqueo eliminado exitosamente',
            onConfirm: () {
              setState(() {
                parqueos.removeWhere((parking) => parking['id'].toString() == parkingId);
              });
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el parqueo: $e')),
      );
    }
  }

  double calculateOccupancy(Map<String, dynamic> parking) {
    int capacity = parking['capacity'] ?? 0;
    int available = parking['spaces_available'] ?? 0;
    if (capacity == 0) return 0.0;
    return (capacity - available) / capacity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis parqueos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigationBarScreen(initialIndex: 3)),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando parqueos...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: parqueos.isEmpty
                        ? Center(
                            child: Text(
                              'No tienes parqueos registrados',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: parqueos.length,
                            itemBuilder: (context, index) {
                              var parqueo = parqueos[index];
                              return InkWell(
                                onTap: () {
                                  ParkingManager.instance.setParking(Parking(
                                      id: parqueo['id'], name: parqueo['name']));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen(
                                            parkingId: parqueo['id'].toString())),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 8.0,
                                            top: 8.0,
                                            bottom: 8.0), // Ajusta los márgenes
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: parqueo['url_image'] != null &&
                                                  parqueo['url_image'].isNotEmpty
                                              ? Image.network(
                                                  parqueo['url_image'],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/Logotipo.png',
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  'assets/images/Logotipo.png',
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                parqueo['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                parqueo['street'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              SizedBox(
  height: 10, // Ajusta esta altura según tus necesidades
  child: LinearProgressIndicator(
    value: calculateOccupancy(parqueo),
    backgroundColor: Colors.grey[300],
    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
  ),
),

                                              SizedBox(height: 4),
                                              Text(
                                                '${parqueo['spaces_available']} de ${parqueo['capacity']} espacios disponibles',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.blue),
                                        onPressed: () async {
                                          await deleteParking(
                                              parqueo['id'].toString());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpParkingPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4285f4),
                      padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 100), // Increase horizontal padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Añadir Parqueo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
