import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/managers/VehicleManager.dart';
import 'package:map_flutter/common/widgets/CustomInfoRow.dart';
import 'package:map_flutter/common/widgets/CustomListTile.dart';
import 'package:map_flutter/common/widgets/LoadingDialog.dart';
import 'package:map_flutter/models/Payment.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/models/ReservationVehicleEntry.dart';
import 'package:map_flutter/models/VehicleEntry.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_reservationVehicleEntry.dart';
import 'package:map_flutter/services/payment/QrGenerator.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class PaymentDetails extends StatefulWidget {
  final Reservation reservation;
  const PaymentDetails({super.key, required this.reservation});
  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Metodos de Pago"),
      ),
      body: Column(
        children: [_reservationDetails(), _paymentMethods()],
      ),
    );
  }

  Widget _reservationDetails() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(17),
      margin: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.primary, // Color de fondo del widget
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Detalles de la Reserva",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          InfoRow(label: "Hora de Inicio", value: widget.reservation.startTime),
          InfoRow(label: "Hora de Fin", value: widget.reservation.endTime),
          InfoRow(
              label: "Total Amount",
              value: "\$${widget.reservation.totalAmount.toStringAsFixed(2)}"),
          InfoRow(label: "Precio", value: "${widget.reservation.priceId}"),
          if (widget.reservation.extraTime != null)
            InfoRow(
                label: "Extra Time",
                value: "${widget.reservation.extraTime} minutes"),
          InfoRow(
              label: "Fecha de la reserva",
              value: widget.reservation.reservationDate),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return Column(
      children: [
        CustomListTile(
            title: "Qr Simple",
            icon: Icons.qr_code_scanner,
            onTap: () async {
              LoadingDialog.showLoadingDialog(context,
                  loadingText: "Generando Qr ...");
              try {
                String qrBase64 =
                    await QRCodeService(id: widget.reservation.id.toString())
                        .generateQRCode();
                LoadingDialog.hideLoadingDialog(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRPayment(
                      qrBase64: qrBase64,
                      reservation: widget.reservation,
                    ),
                  ),
                );
              } catch (error) {
                Navigator.of(context)
                    .pop(); // Asegura cerrar el diálogo en caso de error
                print('Error generating QR code: $error');
              }
            }),
        Divider(color: Colors.grey),
        CustomListTile(
            title: "Tarjeta de Debito/Credito",
            iconColor: Color.fromARGB(255, 15, 127, 219),
            icon: Icons.credit_card,
            onTap: () async {
              LoadingDialog.showLoadingDialog(context,
                  loadingText: "cargando ...");

              Payment? payment =
                  await makePayment(widget.reservation.totalAmount);
              LoadingDialog.hideLoadingDialog(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CardDebitCredit(
                            payment: payment!,
                            reservation: widget.reservation,
                          )));
            }),
        Divider(color: Colors.grey),
      ],
    );
  }

  Future<Payment?> makePayment(double totalAmount) async {
    double totalARG = double.parse((totalAmount * 128.33).toStringAsFixed(2));
    final response = await http.post(
      Uri.parse('https://api-sbx.dlocalgo.com/v1/payments'),
      headers: {
        'authorization':
            'Bearer RtJZkjQOcgoaXEJaJsRsSjtmPVSSsmmL:4NVVLk2gf4g5KJZHgT0Fvt7olF7iKnmoqZdjgMXT',
        'content-type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'amount': totalARG,
        'currency': 'ARS',
        'country': 'AR',
      }),
    );
    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to load payment');
      return null;
    }
  }
}

class CardDebitCredit extends StatelessWidget {
  const CardDebitCredit(
      {super.key, required this.payment, required this.reservation});
  final Payment payment;
  final Reservation reservation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              final response = await http.get(
                Uri.parse(
                    'https://api-sbx.dlocalgo.com/v1/payments/${payment.id}'),
                headers: {
                  'Authorization':
                      'Bearer RtJZkjQOcgoaXEJaJsRsSjtmPVSSsmmL:4NVVLk2gf4g5KJZHgT0Fvt7olF7iKnmoqZdjgMXT',
                },
              );
              if (response.statusCode == 200) {
                var data = jsonDecode(response.body);
                if (data['status'] == 'PAID') {
                  //ApiReservation().create(newReservation);
                  reservation.state = ReservationState.confirmed;
                  ApiReservationVehicleEntry().create(ReservationVehicleEntry(
                      reservationData: reservation,
                      vehicleEntryData: VehicleEntry(
                        user: Provider.of<TokenProvider>(context, listen: false)
                            .userId!,
                        vehicle: VehicleManager.instance.getId()!,
                        parking: ParkingManager.instance.parking!.id!,
                      )));

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigationBarScreen()));
                } else {
                  Navigator.pop(context);
                }
              } else {
                print('Failed to check payment status');
              }
            }),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 1000),
          child: WebView(
            initialUrl: payment.redirectUrl,
            javascriptMode: JavascriptMode.unrestricted,
            key: const ValueKey('webview'),
          ),
        ),
      ),
    );
  }
}

class QRPayment extends StatelessWidget {
  final String qrBase64;
  final Reservation reservation;
  const QRPayment(
      {super.key, required this.qrBase64, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Payment'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                reservation.state = ReservationState.pending;
                ApiReservationVehicleEntry().create(ReservationVehicleEntry(
                    reservationData: reservation,
                    vehicleEntryData: VehicleEntry(
                      user: Provider.of<TokenProvider>(context, listen: false)
                          .userId!,
                      vehicle: VehicleManager.instance.getId()!,
                      parking: ParkingManager.instance.parking!.id!,
                    )));

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NavigationBarScreen()));
              }),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Image.memory(base64Decode(qrBase64)),
                ),
              ),
              SizedBox(height: 20),
              Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: ButtonTheme(
                    minWidth: 200,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadQRImage(context),
                      icon: Icon(Icons.download),
                      label: Text('Descargar QR'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue), // Color de fondo del botón
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Color del texto y el icono
                        elevation: MaterialStateProperty.all<double>(
                            3), // Elevación del botón
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                        ),
                      ),
                    ),
                  )
                  // Espacio entre la imagen y el botón
                  ),
              Container(
                  margin: EdgeInsets.only(bottom: 60),
                  child: ButtonTheme(
                    minWidth: 200,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        reservation.state = ReservationState.pending;
                        ApiReservationVehicleEntry()
                            .create(ReservationVehicleEntry(
                                reservationData: reservation,
                                vehicleEntryData: VehicleEntry(
                                  user: Provider.of<TokenProvider>(context,
                                          listen: false)
                                      .userId!,
                                  vehicle: 91,
                                  parking: ParkingManager.instance.parking!.id!,
                                )));

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavigationBarScreen()));
                      },
                      icon: Icon(Icons.monetization_on),
                      label: Text('Guardar y pagar mas tarde'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue), // Color de fondo del botón
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Color del texto y el icono
                        elevation: MaterialStateProperty.all<double>(
                            3), // Elevación del botón
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                        ),
                      ),
                    ),
                  ) //],
                  ),
            ]));
  }

  Future<void> _downloadQRImage(BuildContext context) async {
    final Uint8List bytes = base64Decode(qrBase64);
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final result = await ImageGallerySaver.saveImage(
          bytes,
          name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen guardada en la galería'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error al guardar la imagen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la imagen'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permiso de almacenamiento denegado'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
