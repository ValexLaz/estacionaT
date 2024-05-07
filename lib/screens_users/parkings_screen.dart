import 'dart:math';

import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/parking_details_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

class ParkingsScreen extends StatefulWidget {
  const ParkingsScreen({Key? key}) : super(key: key);

  @override
  State<ParkingsScreen> createState() => _ParkingsScreenState();
}

class _ParkingsScreenState extends State<ParkingsScreen> {
  final ApiParking apiParking = ApiParking();
  List<Map<String, dynamic>> parkings = [];
  List<Map<String, dynamic>> filteredParkings = [];
  List<Map<String, dynamic>> searchFilteredParkings = [];
  Color primaryColor = Color(0xFF1b4ee4);
  TextEditingController searchController = TextEditingController();
  int selectedFilterIndex = 1;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> data = await apiParking.getAllParkings();
      setState(() {
        parkings = data;
        filteredParkings = data;
      });
      filterParkings(selectedFilterIndex);
    } catch (e) {
      print('Error al obtener datos de parqueos: $e');
    }
  }

  void filterParkings(int index) {
    setState(() {
      selectedFilterIndex = index;
    });
    switch (index) {
      case 3:
        List<Map<String, dynamic>> shuffledParkings = List.from(parkings);
        shuffledParkings.shuffle(random); // Mezcla los parqueos aleatoriamente
        filteredParkings = shuffledParkings;
        break;
      case 1:
        filteredParkings =
            parkings.where((p) => p['spaces_available'] > 0).toList();
        break;
      case 2:
        filteredParkings =
            parkings.where((p) => p['spaces_available'] <= 0).toList();
        break;
      case 3:
        filteredParkings =
            parkings; // Restablece a todos los parqueos sin filtro
        break;
      default:
        filteredParkings = parkings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              children: [
                Text('Parqueos',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                Divider(color: Colors.grey),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar parqueos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              onChanged: (value) {
                searchFilteredParkings = filteredParkings.where((parking) {
                  String parkingName = parking['name'].toLowerCase();
                  return parkingName.contains(value.toLowerCase());
                }).toList();
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  filterButton(0, 'Cerca de ti'),
                  SizedBox(width: 5), // Espacio entre los botones
                  filterButton(1, 'Disponibles'),
                  SizedBox(width: 5), // Espacio entre los botones
                  filterButton(2, 'No Disponibles'),
                  SizedBox(width: 5), // Espacio entre los botones
                  filterButton(3, 'Todos'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchController.text.isNotEmpty
                  ? searchFilteredParkings.length
                  : filteredParkings.length,
              itemBuilder: (context, index) {
                var parking = searchController.text.isNotEmpty
                    ? searchFilteredParkings[index]
                    : filteredParkings[index];
                int spacesAvailable = parking['spaces_available'];
                bool isAvailable = spacesAvailable > 0;
                String availabilityText =
                    isAvailable ? '$spacesAvailable espacios' : 'Sin espacios';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingDetailsScreen(
                          parkingId: parking['id'].toString(),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/Logotipo.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parking['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text("Tarifa: 0.00 Bs",
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isAvailable ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(
                                        10), // Esquinas redondeadas
                                  ),
                                  child: Text(
                                    availabilityText,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 40.0,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
             builder: (context) => NavigationBarScreen(),
           ));
         },
         label: Text(
           'Ver mapa',
           style: TextStyle(
             color:
                 primaryColor, // Color del texto igual al del icono y el margen
           ),
         ),
         icon: Icon(
           Icons.map,
           color: primaryColor,
         ),
         backgroundColor: Colors.white,
         foregroundColor: Colors.white, // Color del texto
         shape: RoundedRectangleBorder(
           side: BorderSide(color: primaryColor),
           borderRadius: BorderRadius.circular(8.0),
         ),
       ),
     ),
   );
 }

 Widget filterButton(int index, String text) {
   return ElevatedButton(
     style: ElevatedButton.styleFrom(
       backgroundColor:
           selectedFilterIndex == index ? primaryColor : Colors.white,
       side: BorderSide(
         color:
             selectedFilterIndex == index ? Colors.transparent : primaryColor,
         width: 1,
       ),
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(10),
       ),
     ),
     onPressed: () => filterParkings(index),
     child: Text(
       text,
       style: TextStyle(
         color: selectedFilterIndex == index ? Colors.white : primaryColor,
       ),
     ),
   );
 }
}