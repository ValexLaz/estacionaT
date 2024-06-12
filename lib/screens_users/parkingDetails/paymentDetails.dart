import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
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
              LoadingDialog.showLoadingDialog(context,loadingText: "Generando Qr ...");
              try {
                String qrBase64 = await QRCodeService().generateQRCode();
                LoadingDialog.hideLoadingDialog(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRPayment(qrBase64: qrBase64),
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
              LoadingDialog.showLoadingDialog(context,loadingText: "cargando ...");

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
  const CardDebitCredit({super.key, required this.payment, required this.reservation});
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

                  ApiReservationVehicleEntry().create(ReservationVehicleEntry(
                      reservationData: reservation,
                      vehicleEntryData: VehicleEntry(
                        user: Provider.of<TokenProvider>(context, listen: false)
                            .userId!,
                        vehicle: 2,
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
  const QRPayment({super.key, required this.qrBase64});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
          height: 300,
          child: Center(
            child: Image.memory(base64Decode(qrBase64)),
          )),
    );
  }
}