import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/screens_owners/create_account_owner.dart';
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';
import 'package:map_flutter/screens_users/account_user.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';

class ListParkings extends StatefulWidget {
  const ListParkings({Key? key}) : super(key: key);

  @override
  State<ListParkings> createState() => _ListParkingsState();
}

class _ListParkingsState extends State<ListParkings> {
  final ApiParking apiParking = ApiParking();
  List<Map<String, dynamic>> parqueos = [];
  Color primaryColor = Color(0xFF1b4ee4);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? authToken =
        Provider.of<TokenProvider>(context, listen: false).token;
    fetchData(authToken);
  }

  Future<void> fetchData(String? token) async {
    try {
      List<Map<String, dynamic>> data =
          await apiParking.getParkingsByUserId(token!);
      setState(() {
        parqueos = data;
      });
    } catch (e) {
      print('Error al obtener datos de parqueos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Todos los Parqueos', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CuentaScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpParkingPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1b4ee4),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            child: Text(
              'Registrar Parqueo',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
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
                      bool isAvailable = parqueo['spaces_available'] > 0;
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
                          margin: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/Logotipo.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        parqueo['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Text(
                                          'Espacios disponibles: ${parqueo['spaces_available']}'),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 8,
                                        ),
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        child: Text(
                                          isAvailable
                                              ? 'Disponible'
                                              : 'No disponible',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await apiParking.deleteParkingById(
                                        parqueo['id'].toString());
                                    setState(() {
                                      parqueos.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Parqueo eliminado correctamente'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error al eliminar el parqueo: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
