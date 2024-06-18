import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:map_flutter/models/user.dart';

class QRCodeService {
  final String id;
  final String tokenSecret = "9E7BC239DDC04F83B49FFDA5";
  final String tokenService = "51247fae280c20410824977b0781453df59fad5b23bf2a0d14e884482f91e09078dbe5966e0b970ba696ec4caf9aa5661802935f86717c481f1670e63f35d5041c31d7cc6124be82afedc4fe926b806755efe678917468e31593a5f427c79cdf016b686fca0cb58eb145cf524f62088b57c6987b3bb3f30c2082b640d7c52907";
  final String commerceId = "d029fa3a95e174a19934857f535eb9427d967218a36ea014b70ad704bc6c8d1c";

  final List<CartItem> cartItems = [
      CartItem(product_name: "Producto1", qty: 1)
  ];

  QRCodeService({required this.id});

  Future<String> generateQRCode() async {
    try {
      final paymentNumber = await getNextPaymentNumber();
      final postData = jsonEncode({
        "tcCommerceID": commerceId,
        "tnMoneda": "1",
        "tnTelefono": "777777",
        "tcCorreo": "prueba@gmail.com",
        "tcNombreUsuario": "Jhon Doe",
        "tnCiNit": "123465",
        "tcNroPago": paymentNumber,
        "tnMontoClienteEmpresa": 0.01,
        "tcUrlCallBack": "https://estacionatbackend.onrender.com/api/v2/reservation/reservations/payment/$id/",
        "tcUrlReturn": "",
        "taPedidoDetalle": cartItems.map((item) => {
          "Serial": item.qty,
          "Producto": item.product_name,
          "Cantidad": item.qty,
          "Precio": 0.01,
          "Descuento": 0,
          "Total": 0.01
        }).toList()
      });

      final headers = {
        'Content-Type': 'application/json',
        'TokenSecret': tokenSecret,
        'TokenService': tokenService,
        'CommerceId': commerceId,
      };

      final response = await http.post(
        Uri.parse('https://serviciostigomoney.pagofacil.com.bo/api/servicio/generarqrv2'),
        headers: headers,
        body: postData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data != null && data['values'] != null) {
          final parts = data['values'].split(';');
          if (parts.length > 1) {
            final qrData = jsonDecode(parts[1]);
            final qrBase64 = qrData['qrImage'];
            return qrBase64;
          } else {
            print('QR base64 no encontrado en la respuesta.');
          }
        } else {
          print('La respuesta del servidor no contiene "values" o es incorrecta.');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al generar el código QR: $error');
    }
    return '';
  }

  Future<String> getNextPaymentNumber() async {
    return "Grupo5-17";
  }

  Future<String> createOrder(User user, List<CartItem> cartItems) async {
    return "orderId123";
  }
}

class CartItem {
  final String product_name;
  final int qty;

  CartItem({
    required this.product_name,
    required this.qty,
  });
}
