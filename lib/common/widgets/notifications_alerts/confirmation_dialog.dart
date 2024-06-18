import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.blue, size: 48),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: Text(
                      'Listo',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
