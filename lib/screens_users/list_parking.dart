import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

import '../screens_gerentes/create_account_gerente.dart';

class ListParkings extends StatefulWidget {
  const ListParkings({super.key});

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
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> data =
          await apiParking.getAllParkingsByUserID("2");
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
        title: Text('Mis Parqueos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                vertical:
                    16), // Ajusta el margen superior e inferior según sea necesario
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpParkingPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text(
                'Agregar parqueo',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: parqueos.length,
                itemBuilder: (context, index) {
                  var parqueo = parqueos[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/Logotipo.png', // Imagen predeterminada
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parqueo['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1b4ee4),
                                  ),
                                ),
                                Text(
                                  "Santa cruz",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  "15 bs",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 8,
                                  ),
                                  color: true ? Colors.green : Colors.red,
                                  child: Text(
                                    true ? 'Disponible' : 'No disponible',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.location_on, color: Color(0xFF1b4ee4)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NavigationBarScreen(),
                            ));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
