import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/services/api_parking.dart';

class OpeningHoursScreen extends StatefulWidget {
  final int parkingId;

  OpeningHoursScreen({required this.parkingId});

  @override
  _OpeningHoursScreenState createState() => _OpeningHoursScreenState();
}

class _OpeningHoursScreenState extends State<OpeningHoursScreen> {
  late Future<List<OpeningHours>> _futureOpeningHours;

  @override
  void initState() {
    super.initState();
    _futureOpeningHours =
        ApiOpeningHours().getOpeningHoursByParkingId(widget.parkingId);
  }

  Future<void> _refreshOpeningHours() async {
    setState(() {
      _futureOpeningHours =
          ApiOpeningHours().getOpeningHoursByParkingId(widget.parkingId);
    });
  }

  void _navigateToEditScreen(OpeningHours hour) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOpeningHourScreen(openingHour: hour),
      ),
    );

    if (result == true) {
      _refreshOpeningHours();
    }
  }

  void _navigateToCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateOpeningHourScreen(parkingId: widget.parkingId),
      ),
    );

    if (result == true) {
      _refreshOpeningHours();
    }
  }

  void _deleteOpeningHour(int openingHourId) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar este horario?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Eliminar'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await ApiOpeningHours().deleteOpeningHour(openingHourId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Horario eliminado exitosamente')),
        );
        _refreshOpeningHours();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar horario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horarios de Atención'),
      ),
      body: FutureBuilder<List<OpeningHours>>(
        future: _futureOpeningHours,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron horarios.'));
          } else {
            List<OpeningHours> openingHours = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshOpeningHours,
              child: ListView.builder(
                itemCount: openingHours.length,
                itemBuilder: (context, index) {
                  OpeningHours hour = openingHours[index];
                  String openTime = formatTime(hour.open_time);
                  String closeTime = formatTime(hour.close_time);
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.access_time, color: Colors.blue),
                      title: Text(
                        hour.day ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Horario: $openTime - $closeTime'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToEditScreen(hour),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOpeningHour(hour.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        child: Icon(Icons.add),
        tooltip: 'Registrar horario',
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return time;
  }
}

class EditOpeningHourScreen extends StatefulWidget {
  final OpeningHours openingHour;

  EditOpeningHourScreen({required this.openingHour});

  @override
  _EditOpeningHourScreenState createState() => _EditOpeningHourScreenState();
}

class _EditOpeningHourScreenState extends State<EditOpeningHourScreen> {
  late TextEditingController _dayController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(text: widget.openingHour.day);
    _openTimeController =
        TextEditingController(text: formatTime(widget.openingHour.open_time));
    _closeTimeController =
        TextEditingController(text: formatTime(widget.openingHour.close_time));
  }

  @override
  void dispose() {
    _dayController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  void _updateOpeningHour() async {
    final updatedHour = OpeningHours(
      id: widget.openingHour.id,
      day: _dayController.text,
      open_time: _openTimeController.text,
      close_time: _closeTimeController.text,
      parking: widget.openingHour.parking,
    );

    try {
      await ApiOpeningHours()
          .updateOpeningHour(widget.openingHour.id!, updatedHour);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horario actualizado exitosamente')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar horario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Horario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(_dayController, "Día", Icons.calendar_today),
            const SizedBox(height: 20),
            _buildInputField(_openTimeController, "Hora de Apertura", Icons.access_time),
            const SizedBox(height: 20),
            _buildInputField(_closeTimeController, "Hora de Cierre", Icons.access_time),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: _updateOpeningHour,
                icon: Icon(Icons.save),
                label: Text('Actualizar Horario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return time;
  }
}

class CreateOpeningHourScreen extends StatefulWidget {
  final int parkingId;

  CreateOpeningHourScreen({required this.parkingId});

  @override
  _CreateOpeningHourScreenState createState() =>
      _CreateOpeningHourScreenState();
}

class _CreateOpeningHourScreenState extends State<CreateOpeningHourScreen> {
  late TextEditingController _dayController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController();
    _openTimeController = TextEditingController();
    _closeTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  void _registerOpeningHour() async {
    final newHour = {
      'day': _dayController.text,
      'open_time': _openTimeController.text,
      'close_time': _closeTimeController.text,
      'parking': widget.parkingId,
    };

    try {
      await ApiParking().createOpeningHours(newHour);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Horario registrado exitosamente')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar horario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Horario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(_dayController, "Día", Icons.calendar_today),
            const SizedBox(height: 20),
            _buildInputField(_openTimeController, "Hora de Apertura", Icons.access_time),
            const SizedBox(height: 20),
            _buildInputField(_closeTimeController, "Hora de Cierre", Icons.access_time),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: _registerOpeningHour,
                icon: Icon(Icons.add),
                label: Text('Registrar Horario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return time;
  }
}

String formatTime(String? time) {
  if (time == null || time.isEmpty) return '';
  final timeParts = time.split(':');
  if (timeParts.length >= 2) {
    return '${timeParts[0]}:${timeParts[1]}';
  }
  return time;
}
