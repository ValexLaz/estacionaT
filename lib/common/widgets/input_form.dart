import 'package:flutter/material.dart';

class InputForm extends StatelessWidget {
  final Widget inputWidget;
  final String name;
  final EdgeInsetsGeometry? margin;
  
  const InputForm({
    required this.inputWidget,
    required this.name,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectiveMargin =
        margin ?? EdgeInsets.only(top: 20);

    return Container(
      margin: effectiveMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.grey),
          ),
          inputWidget,
        ],
      ),
    );
  }
}
