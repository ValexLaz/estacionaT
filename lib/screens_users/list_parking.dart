import 'package:flutter/material.dart';
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/parking_details_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

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
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> data = await apiParking.getAllParkings();
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
        title: Text('Todos los Parqueos', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: parqueos.length,
              itemBuilder: (context, index) {
                var parqueo = parqueos[index];
                bool isAvailable = parqueo['spaces_available'] > 0; // Asumiendo que 'spaces_available' es un int

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(),
                      ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color:
                                      isAvailable ? Colors.green : Colors.red,
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
                          icon:
                              Icon(Icons.location_on, color: primaryColor),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NavigationBarScreen(),
                            ));
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
