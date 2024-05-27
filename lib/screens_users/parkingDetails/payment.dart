import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
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

class PaymentScreen extends StatefulWidget {
  final Payment payment;
  final String qrBase64;
  final Reservation reservation;
  const PaymentScreen(
      {super.key, required this.payment, required this.reservation, required this.qrBase64});
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late List<Item>   _data ;

  @override
  void initState() {
    super.initState();
    _data = [
      Item(
        headerValue: 'Pagar con tarjeta',
        expandedValue: '',
        widget: SizedBox(
          height: 800,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 1000
              ),
              child: WebView(
            initialUrl: widget.payment.redirectUrl,
            javascriptMode: JavascriptMode.unrestricted,
            key: const ValueKey('webview'),
          ), 
            ),
            
          )
        ),
      ),
      Item(
        headerValue: 'Pagar con Qr',
        expandedValue: '',
        widget: SizedBox(
          height: 300,
          child: Image.memory(base64Decode(widget.qrBase64)),
        ),
      )
    ];
  }

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
                    'https://api-sbx.dlocalgo.com/v1/payments/${widget.payment.id}'),
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
                      reservationData: widget.reservation,
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
        child: Container(
          child: _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !_data[index].isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
              child: ListTile(
                title: Text(item.headerValue),
              ),
            );
          },
          body: item.widget,
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class Item {
  Widget widget;
  String expandedValue;
  String headerValue;
  bool isExpanded;

  Item(
      {required this.widget,
      required this.expandedValue,
      required this.headerValue,
      this.isExpanded = false});
}
