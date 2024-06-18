import 'package:flutter/material.dart';

class InputMultipleOptions extends StatefulWidget {
  final List<String> options;
  final TextEditingController controller;
  final IconData icon;
  final void Function(String?) onChanged;

  const InputMultipleOptions({
    Key? key,
    required this.options,
    required this.controller,
    required this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  _InputMultipleOptionsState createState() => _InputMultipleOptionsState();
}

class _InputMultipleOptionsState extends State<InputMultipleOptions> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.controller.text.isNotEmpty ? widget.controller.text : null,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon)
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          widget.controller.text = newValue;
          widget.onChanged(newValue); 
        } else {
          widget.controller.text = '';
          widget.onChanged(null); 
        }
        setState(() {}); 
      },
      items: widget.options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      hint: Text('Seleccione una opción'),
    );
  }
}
