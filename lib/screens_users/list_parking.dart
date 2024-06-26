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
              Navigator.of(context).pop(); // Close the dialog
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

  void confirmDeleteParking(String parkingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este parqueo? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteParking(parkingId);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
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
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
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
                                    title: Text(
                                      parqueo['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 17,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parqueo['street'] ?? '',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                  
                                        SizedBox(height: 4),
                                        Text(
                                          '${parqueo['capacity']} espacios disponibles',
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        confirmDeleteParking(parqueo['id'].toString());
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.black,
                                    thickness: 1,
                                    height: 1,
                                    indent: 0,
                                    endIndent: 0,
                                  ),
                                ],
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
                          vertical: 12, horizontal: 100),
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
