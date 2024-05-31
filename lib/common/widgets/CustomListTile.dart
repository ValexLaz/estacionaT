import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color textColor;
  final VoidCallback onTap;
  final Color iconColor;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.textColor  = Colors.black,
    this.iconColor = Colors.black,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.secondary, size: 16),
      onTap: onTap,
    );
  }
}
