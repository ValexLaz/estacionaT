import 'package:flutter/material.dart';

class AlertSnackBar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  EdgeInsets margin;

  AlertSnackBar({
    required this.message,
    required this.backgroundColor,
    this.margin =const  EdgeInsets.only(right: 16.0) ,
    
  });

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: margin,
    );
  }
}
