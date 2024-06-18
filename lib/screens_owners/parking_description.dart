import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/error_message_dialog.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';

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
  bool _isEditing = false; 
  bool _isCancelVisible = false; 

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

        _nameController.text = parkingDetails['name'] ?? '';
        _descriptionController.text = parkingDetails['description'] ?? '';
        _spacesAvailableController.text =
            parkingDetails['spaces_available']?.toString() ?? ''; 
        _capacityController.text = parkingDetails['capacity']?.toString() ?? ''; 
        _emailController.text = parkingDetails['email'] ?? '';
        _phoneController.text = parkingDetails['phone'] ?? '';
      });
    } catch (e) {
      print('Error fetching parking details: $e');
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorMessageDialog(
            title: 'Error',
            message: 'Hubo un error al cargar los datos del parqueo.',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color myColor = Theme.of(context).primaryColor;
    final Size mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del Parqueo"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                    Center(
                      child: Column(
                        children: [
                          _isEditing ? _buildSaveButton() : _buildEditButton(),
                          if (_isCancelVisible) _buildCancelButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = false;
              _isCancelVisible = false;
              fetchParkingDetails(); 
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.cancel, color: Colors.white),
          label: Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = true;
              _isCancelVisible = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4285f4),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text(
            'Editar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            _updateParking(context);
            setState(() {
              _isCancelVisible = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4285f4),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.save, color: Colors.white),
          label: Text(
            'Guardar Cambios',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateParking(BuildContext context) async {
    try {
      final parkingDetail = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'spaces_available':
            int.parse(_spacesAvailableController.text), 
        'capacity': int.parse(_capacityController.text), 
        'email': _emailController.text,
        'phone': _phoneController.text,
      };
      await apiParking.updateParkingById(widget.parkingId, parkingDetail);

      setState(() {
        _isEditing = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: 'Éxito',
            message: 'Datos actualizados exitosamente.',
            onConfirm: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } catch (e) {
      print('Error updating parking details: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorMessageDialog(
            title: 'Error',
            message: 'Hubo un error al actualizar los datos del parqueo.',
          );
        },
      );
    }
  }
}
