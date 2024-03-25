import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';

import 'navigation_bar_screen.dart'; // Asegúrate de importar correctamente

class ParqueosScreen extends StatefulWidget {
  @override
  _ParqueosScreenState createState() => _ParqueosScreenState();
}

class _ParqueosScreenState extends State<ParqueosScreen> {
  final ApiParking apiParking = new ApiParking();
  List<Map<String, dynamic>> parqueos = [];

   @override
   void initState(){
    super.initState();
    fetchData();
   }
  Future<void> fetchData() async {
    try {

      List<Map<String, dynamic>> data = await apiParking.getAllRecords();
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
        title: Text('Parqueos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: parqueos.length,
          itemBuilder: (context, index) {
            var parqueo = parqueos[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: Row(
                children: [
                  Image.network(
                    parqueo['url_image'],
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
                                color: Color(0xFF1b4ee4)),
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
                                vertical: 2, horizontal: 8),
                            color: true
                                ? Colors.green
                                : Colors.red,
                            child: Text(
                              true
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
                    icon: Icon(Icons.location_on, color: Color(0xFF1b4ee4)),
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
    );
  }
}
