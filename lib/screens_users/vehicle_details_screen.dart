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

  Map<String, dynamic> getVehicleTypeInfo(int type) {
    switch (type) {
      case 1:
        return {
          'icon': 'assets/Icons/sedan.png',
          'name': 'Sedán',
        };
      case 2:
        return {
          'icon': 'assets/Icons/camioneta.png',
          'name': 'Camioneta',
        };
      case 3:
        return {
          'icon': 'assets/Icons/jeep.png',
          'name': 'Jeep',
        };
      case 4:
        return {
          'icon': 'assets/Icons/vagoneta.png',
          'name': 'Vagoneta',
        };
      case 5:
        return {
          'icon': Icons.motorcycle,
          'name': 'Motocicleta',
        };
      default:
        return {
          'icon': Icons.help,
          'name': 'Desconocido',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Vehículo',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          if (!isLoading)
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: buildVehicleIcon(vehicleDetails['type_vehicle']),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles del Vehículo',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        buildDetailItem('Marca', vehicleDetails['brand']),
                        buildDetailItem('Modelo', vehicleDetails['model']),
                        buildDetailItem('Placa de Registro',
                            vehicleDetails['registration_plate']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget buildVehicleIcon(int? type) {
    if (type == null) {
      return Icon(Icons.help, size: 150, color: Colors.black);
    }
    final typeInfo = getVehicleTypeInfo(type);
    final icon = typeInfo['icon'];

    return icon is IconData
        ? Icon(icon, size: 250, color: Colors.black)
        : Image.asset(icon, width: 250, height: 250, color: Colors.black);
  }

  Widget buildDetailItem(String title, String? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            detail ?? 'No disponible',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
