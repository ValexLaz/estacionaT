import 'package:flutter/material.dart';

class ErrorMessageDialog extends StatelessWidget {
  final String title;
  final String message;

  const ErrorMessageDialog({Key? key, required this.title, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
      ),
      contentPadding: EdgeInsets.zero, // Eliminar padding para asegurar el fondo blanco
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Agregar padding alrededor del contenido
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 8.0), // Espacio entre título y mensaje
              Text(message), // Espacio entre mensaje y botón
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
