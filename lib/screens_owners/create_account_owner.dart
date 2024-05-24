import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/screens_owners/select_map_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';

class SignUpParkingPage extends StatefulWidget {
  const SignUpParkingPage({Key? key}) : super(key: key);

  @override
  State<SignUpParkingPage> createState() => _SignUpParkingPageState();
}

class _SignUpParkingPageState extends State<SignUpParkingPage> {
  final ApiParking apiParking = ApiParking();

  late Color myColor;
  late Size mediaSize;
  TextEditingController parkingNameController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController ownerPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TimeOfDay openingTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closingTime = TimeOfDay(hour: 20, minute: 0);
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<bool> _selectedDays = List<bool>.filled(7, false);
  String _imageUrl = '';

  final List<String> _daysOfWeek = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageFile == null) return;
    String fileName =
        'parking_images/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
    try {
      UploadTask task =
          FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);

      final snapshot = await task;
      final urlDownload = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = urlDownload;
      });

      _showSnackBar('Imagen subida con éxito');
    } catch (e) {
      _showSnackBar('Error al subir imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              "Registrar Parqueo",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cuentanos más acerca de tu parqueo",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Esta información se mostrará en la aplicación para que los clientes puedan encontrarte y reservar un espacio en tu parqueo. También podrán contactarte si tienen alguna pregunta o necesitan asistencia.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField("Nombre del Parqueo", parkingNameController),
                  const SizedBox(height: 20),
                  _buildInputField(
                      "Capacidad Total de Vehículos", capacityController),
                  const SizedBox(height: 20),
                  _buildPhoneInputField("Número de Teléfono del Propietario",
                      ownerPhoneController),
                  const SizedBox(height: 14),
                  _buildInputField("Correo Electrónico", emailController),
                  const SizedBox(height: 12),
                  _buildImagePickerButton(),
                  if (_imageFile != null) ...[
                    Image.file(
                      _imageFile!,
                      height: 250,
                      width: 250,
                    ),
                    _buildUploadImageButton(),
                  ],
                  const SizedBox(height: 12),
                  _buildInputField("Descripción", descriptionController),
                  const SizedBox(height: 10),
                  Text(
                    "Horarios de Apertura y Cierre",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Seleccionar toda la semana",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Switch(
                        value: _selectedDays.every((day) => day),
                        onChanged: (bool value) {
                          setState(() {
                            _selectedDays = List<bool>.filled(7, value);
                          });
                        },
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.blue,
                        inactiveTrackColor: Colors.white.withOpacity(0.5),
                        trackOutlineColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (!states.contains(MaterialState.selected)) {
                              return Colors.blue;
                            }
                            return null;
                          },
                        ),
                        focusColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDaysSelection(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimePicker("Apertura", openingTime, (newTime) {
                        setState(() => openingTime = newTime);
                      }),
                      _buildTimePicker("Cierre", closingTime, (newTime) {
                        setState(() => closingTime = newTime);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context); // Acción para el botón "Anterior"
                      },
                      child: Container(
                        height: 50,
                        color: Colors.white,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.grey),
                              SizedBox(width: 5),
                              Text("Anterior",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_validateInputs()) {
                          final tokenProvider = Provider.of<TokenProvider>(
                              context,
                              listen: false);
                          final userId = tokenProvider.userId;

                          Map<String, dynamic> parkingData = {
                            "name": parkingNameController.text,
                            "capacity":
                                int.tryParse(capacityController.text) ?? 0,
                            "phone": '+591${ownerPhoneController.text}',
                            "email": emailController.text,
                            "user": userId,
                            "url_image": _imageUrl,
                            "description": descriptionController.text,
                            "spaces_available":
                                int.tryParse(capacityController.text) ?? 0,
                          };

                          try {
                            final parkingId =
                                await apiParking.createRecord(parkingData);
                            print("Parqueo registrado con ID: $parkingId");
                            final ApiOpeningHours apiOpeningHours =
                                ApiOpeningHours();

                            for (int i = 0; i < _selectedDays.length; i++) {
                              if (_selectedDays[i]) {
                                await apiOpeningHours.create(OpeningHours(
                                  day: _daysOfWeek[i],
                                  parking: int.parse(parkingId),
                                  open_time:
                                      "${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00",
                                  close_time:
                                      "${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00",
                                ));
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectMapScreen(
                                    parkingId: int.parse(parkingId)),
                              ),
                            );
                          } catch (e) {
                            print("Error al registrar el parqueo: $e");
                            _showSnackBar(
                                'Error al registrar el parqueo. Por favor, inténtelo de nuevo.');
                          }
                        }
                      },
                      child: Container(
                        height: 50,
                        color: Colors.white,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Siguiente",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);

    if (parkingNameController.text.isEmpty ||
        capacityController.text.isEmpty ||
        ownerPhoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        !emailValid ||
        _imageUrl.isEmpty ||
        descriptionController.text.isEmpty ||
        !_selectedDays.contains(true)) {
      _showSnackBar(
          'Por favor, complete todos los campos correctamente antes de continuar.');
      return false;
    }
    if (int.tryParse(capacityController.text) == null) {
      _showSnackBar('Ingrese un número válido en el campo de capacidad.');
      return false;
    }
    if (ownerPhoneController.text.length != 8 ||
        int.tryParse(ownerPhoneController.text) == null) {
      _showSnackBar('Ingrese un número de teléfono válido de 8 dígitos.');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildImagePickerButton() {
    return ElevatedButton.icon(
      onPressed: _pickImage,
      icon: Icon(Icons.image, color: Colors.white),
      label: Text('Seleccionar imagen', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildUploadImageButton() {
    return ElevatedButton.icon(
      onPressed: _uploadImageToFirebase,
      icon: Icon(Icons.cloud_upload, color: Colors.white),
      label: Text('Subir', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDays[index] = !_selectedDays[index];
                });
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedDays[index] ? Colors.blue : Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _daysOfWeek[index][0],
                      style: TextStyle(
                        color:
                            _selectedDays[index] ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField(String label, TextEditingController controller) {
    return SizedBox(
      height: 70,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.phone,
        maxLength: 8,
      ),
    );
  }

  Widget _buildTimePicker(
      String label, TimeOfDay time, ValueChanged<TimeOfDay> onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
              initialEntryMode: TimePickerEntryMode.input,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      dialHandColor: Colors.blue,
                      entryModeIconColor: Colors.blue,
                      dayPeriodTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white
                              : Colors.blue),
                      dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? Colors.blue
                              : Colors.white),
                      dayPeriodShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        side: BorderSide(color: Colors.blue),
                      ),
                      hourMinuteTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white
                              : Colors.blue),
                      hourMinuteShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: false),
                    child: child ?? Container(),
                  ),
                );
              },
            );
            if (picked != null && picked != time) {
              onTimeChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
