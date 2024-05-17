import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/models/OpeningHours.dart';

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
    // Aquí puedes implementar la lógica para navegar a la pantalla de edición
    // y pasar el objeto OpeningHours correspondiente como argumento.
    // Después de la edición, puedes refrescar la lista.
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
            return ListView.builder(
              itemCount: openingHours.length,
              itemBuilder: (context, index) {
                OpeningHours hour = openingHours[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hour.day ?? ''),
                        SizedBox(height: 8),
                        Text('Horario: ${hour.open_time} - ${hour.close_time}'),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _navigateToEditScreen(hour),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteOpeningHour(hour.id!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
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
        TextEditingController(text: widget.openingHour.open_time);
    _closeTimeController =
        TextEditingController(text: widget.openingHour.close_time);
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
            TextField(
              controller: _dayController,
              decoration: InputDecoration(labelText: 'Día'),
            ),
            TextField(
              controller: _openTimeController,
              decoration: InputDecoration(labelText: 'Hora de Apertura'),
            ),
            TextField(
              controller: _closeTimeController,
              decoration: InputDecoration(labelText: 'Hora de Cierre'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateOpeningHour,
              child: Text('Actualizar Horario'),
            ),
          ],
        ),
      ),
    );
  }
}
