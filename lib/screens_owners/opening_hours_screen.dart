import 'package:flutter/material.dart';
import 'package:map_flutter/models/OpeningHours.dart';

class OpeningHoursScreen extends StatefulWidget {
  @override
  _OpeningHoursScreenState createState() => _OpeningHoursScreenState();
}

class _OpeningHoursScreenState extends State<OpeningHoursScreen> {
  List<OpeningHours> OpeningHourss = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horarios de atencion'),
      ),
      body: ListView.builder(
        itemCount: OpeningHourss.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                '${OpeningHourss[index].day}: ${OpeningHourss[index].open_time} - ${OpeningHourss[index].close_time}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _agregarOpeningHours(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _agregarOpeningHours(BuildContext context) async {
    String? day;

    TimeOfDay? startTime = TimeOfDay.now(); // Cambio: Inicializar como nulo
    TimeOfDay? endTime = TimeOfDay.now(); // Cambio: Inicializar como nulo

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Agregar Horario de Atencion'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: day,
                      onChanged: (String? newValue) {
                        setState(() {
                          day = newValue;
                        });
                      },
                      items: <String>[
                        'Lunes',
                        'Martes',
                        'Miércoles',
                        'Jueves',
                        'Viernes',
                        'Sábado',
                        'Domingo'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(labelText: 'Día'),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      title: Text(
                          'Hora de Inicio: ${startTime?.format(context)}'), // Cambio: Mostrar hora seleccionada
                      trailing: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: startTime ??
                                TimeOfDay
                                    .now(), // Cambio: Usar hora seleccionada o hora actual
                          );
                          if (picked != null && picked != startTime) {
                            setState(() {
                              startTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                          'Hora de Fin: ${endTime?.format(context)}'), // Cambio: Mostrar hora seleccionada
                      trailing: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: endTime ??
                                TimeOfDay
                                    .now(), // Cambio: Usar hora seleccionada o hora actual
                          );
                          if (picked != null && picked != endTime) {
                            setState(() {
                              endTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (day != null &&
                        day!.isNotEmpty &&
                        startTime != null &&
                        endTime != null) {
                      // Cambio: Verificar que startTime y endTime no sean nulos
                      final nuevo = OpeningHours(
                          day: day!,
                          open_time: startTime.toString(),
                          close_time:
                              endTime.toString()); // Cambio: Utilizar ! para asegurar que startTime y endTime no son nulos
                      setState(() {
                        OpeningHourss.add(nuevo);
                      });
                      Navigator.of(context).pop(nuevo);
                    }
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
