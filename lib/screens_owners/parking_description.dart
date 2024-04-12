import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:provider/provider.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final String parkingId;

  const ParkingDetailsScreen({Key? key, required this.parkingId})
      : super(key: key);

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  final ApiParking apiParking = ApiParking();
  Map<String, dynamic> parkingDetails = {};
  bool isLoading = true;
  bool _isEditing = false; // Estado para controlar si se está editando
  bool _isCancelVisible =
      false; // Estado para controlar la visibilidad del botón cancelar

  // Controladores de los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _spacesAvailableController;
  late TextEditingController _capacityController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    fetchParkingDetails();
    // Inicializa los controladores de texto
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _spacesAvailableController = TextEditingController();
    _capacityController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  Future<void> fetchParkingDetails() async {
    try {
      Map<String, dynamic> parkingDetail =
          await apiParking.getParkingDetailsById(widget.parkingId);
      setState(() {
        parkingDetails = parkingDetail;
        isLoading = false;

        // Carga los datos obtenidos en los controladores de texto
        _nameController.text = parkingDetails['name'] ?? '';
        _descriptionController.text = parkingDetails['description'] ?? '';
        _spacesAvailableController.text =
            parkingDetails['spaces_available']?.toString() ??
                ''; // Convertir a String si es int
        _capacityController.text = parkingDetails['capacity']?.toString() ??
            ''; // Convertir a String si es int
        _emailController.text = parkingDetails['email'] ?? '';
        _phoneController.text = parkingDetails['phone'] ?? '';
      });
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Parqueo'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                      _nameController, "Nombre", Icons.local_parking,
                      enabled: _isEditing),
                  const SizedBox(height: 20),
                  _buildInputField(
                      _descriptionController, "Descripción", Icons.description,
                      enabled: _isEditing),
                  const SizedBox(height: 20),
                  _buildInputField(_spacesAvailableController,
                      "Espacios Disponibles", Icons.space_dashboard_outlined,
                      enabled: _isEditing),
                  const SizedBox(height: 20),
                  _buildInputField(
                      _capacityController, "Capacidad", Icons.group_add,
                      enabled: _isEditing),
                  const SizedBox(height: 20),
                  _buildInputField(_emailController, "Email", Icons.email,
                      enabled: _isEditing),
                  const SizedBox(height: 20),
                  _buildInputField(_phoneController, "Teléfono", Icons.phone,
                      enabled: _isEditing),
                  const SizedBox(height: 40),
                  _isEditing ? _buildSaveButton() : _buildEditButton(),
                  if (_isCancelVisible) SizedBox(height: 10),
                  if (_isCancelVisible) _buildCancelButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String labelText, IconData icon,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      enabled: enabled,
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isEditing = true;
          _isCancelVisible = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text('Editar', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _updateParking(context);
        setState(() {
          _isCancelVisible = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isEditing = false;
          _isCancelVisible = false;
          fetchParkingDetails(); // Carga de nuevo los datos originales al cancelar
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text('Cancelar', style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> _updateParking(BuildContext context) async {
    try {
      final parkingDetail = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'spaces_available':
            int.parse(_spacesAvailableController.text), // Convertir a int
        'capacity': int.parse(_capacityController.text), // Convertir a int
        'email': _emailController.text,
        'phone': _phoneController.text,
      };
      await apiParking.updateParkingById(widget.parkingId, parkingDetail);

      // Si la actualización es exitosa, desactivar el modo de edición
      setState(() {
        _isEditing = false;
      });
      // Muestra un SnackBar con el mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos actualizados exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating parking details: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al actualizar los datos del parqueo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }
}
