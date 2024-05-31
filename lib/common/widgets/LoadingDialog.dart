import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String loadingText = "Cargando",
    bool barrierDismissible = false,  
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,  
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(loadingText),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
