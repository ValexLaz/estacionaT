import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart'; // Asumiendo que la API de vehículos está aquí

class VehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({Key? key, required this.vehicleId})
      : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final ApiVehicle apiVehicle = ApiVehicle();
  Map<String, dynamic> vehicleDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicleDetails();
  }

  Future<void> fetchVehicleDetails() async {
    try {
      Map<String, dynamic> vehicleDetail =
          await apiVehicle.getVehicleDetailsById(widget.vehicleId);
      setState(() {
        vehicleDetails = vehicleDetail;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching vehicle details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Vehículo',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        size: 150, color: Color(0xFF1b4ee4)),
                    SizedBox(height: 24.0),
                    Text(
                      'Marca: ${vehicleDetails['brand'] ?? 'No disponible'}',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Modelo: ${vehicleDetails['model'] ?? 'No disponible'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Placa de Registro: ${vehicleDetails['registration_plate'] ?? 'No disponible'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    // Agrega más campos según sea necesario
                  ],
                ),
              ),
            ),
    );
  }
}
