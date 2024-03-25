import 'package:flutter/material.dart';

import 'navigation_bar_screen.dart'; // Asegúrate de importar correctamente

class ParqueosScreen extends StatefulWidget {
  @override
  _ParqueosScreenState createState() => _ParqueosScreenState();
}

class _ParqueosScreenState extends State<ParqueosScreen> {
  final List<Map<String, dynamic>> parqueos = [
    {
      'imagen': 'https://via.placeholder.com/150',
      'nombre': 'Parqueo Central',
      'ubicacion': 'Calle Principal #123',
      'tarifa': '10 Bs/hora',
      'disponible': true,
    },
    {
      'imagen': 'https://via.placeholder.com/150',
      'nombre': 'Parqueo del Norte',
      'ubicacion': 'Avenida del Parque #456',
      'tarifa': '8 Bs/hora',
      'disponible': false,
    },
    {
      'imagen': 'https://via.placeholder.com/150',
      'nombre': 'Parqueo Sur',
      'ubicacion': 'Zona Sur #789',
      'tarifa': '12 Bs/hora',
      'disponible': true,
    },
  ];

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
                    parqueo['imagen'],
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
                            parqueo['nombre'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1b4ee4)),
                          ),
                          Text(
                            parqueo['ubicacion'],
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            parqueo['tarifa'],
                            style: TextStyle(color: Colors.black),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            color: parqueo['disponible']
                                ? Colors.green
                                : Colors.red,
                            child: Text(
                              parqueo['disponible']
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
