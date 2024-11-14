import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zafiro_conductores/src/models/driver.dart';
import 'package:zafiro_conductores/src/models/client.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../colors/colors.dart';

class BottomSheetClientInfo extends StatefulWidget {
  late String imageUrl;
  late String name;
  late String apellido;
  late String calificacion;
  late String numeroNviajes;
  late String celular;
  final String clientId;

  BottomSheetClientInfo({super.key,
    required this.imageUrl,
    required this.name,
    required this.apellido,
    required this.calificacion,
    required this.numeroNviajes,
    required this.celular,
    required this.clientId,
  });

  @override
  State<BottomSheetClientInfo> createState() => _BottomSheetDriverInfoState();
}

class _BottomSheetDriverInfoState extends State<BottomSheetClientInfo> {
  Client? client;
  Driver? driver;
  late DriverProvider _driverProvider;
  late MyAuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _driverProvider = DriverProvider();
    _authProvider = MyAuthProvider();
    getDriverInfo();
    getClientRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: blancoCards,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildClientInfo(),
          const SizedBox(height: 40),
          _buildActions(),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  Widget _buildClientInfo() {
    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: negro,
                ),
              ),
              Text(
                widget.apellido,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: negro,
                  height: 1
                ),
              ),
              const SizedBox(height: 4),
              const Divider(),
              _buildInfoRow(Icons.route_rounded, 'Viajes:', widget.numeroNviajes),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.star, 'Calificación:', widget.calificacion),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: naranja),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: negro,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: negro,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionCard(Icons.phone, "Llama", () => makePhoneCall(widget.celular)),
        _buildActionCard(null, "Chatea", () => _openWhatsApp(context),
            customIcon: Image.asset('assets/images/icono_whatsapp.png', width: 30, height: 30)),
      ],
    );
  }

  Widget _buildActionCard(IconData? icon, String label, VoidCallback onPressed, {Widget? customIcon}) {
    return Card(
      elevation: 5, // Añade sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Espacio dentro de la tarjeta
        child: Column(
          children: [
            IconButton(
              onPressed: onPressed,
              icon: customIcon ?? Icon(icon, color: Colors.black),
              iconSize: 30,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getClientRatings() async {
    final clientId = widget.clientId;
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('Clients')
        .doc(clientId)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      int ratingCount = ratingsSnapshot.docs.length;

      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['calificacion'];
      }

      double averageRating = totalRating / ratingCount;

      setState(() {
        widget.calificacion = averageRating.toStringAsFixed(1);
      });
    } else {
      setState(() {
        widget.calificacion = 'N/A';
      });
    }
  }

  void getDriverInfo() async {
    driver = await _driverProvider.getById(_authProvider.getUser()!.uid);
  }

  void _openWhatsApp(BuildContext context) async {
    final phoneNumber = '+57${widget.celular}';
    String? name = driver?.the01Nombres;
    String? nameUser = widget.name;
    String message = 'Hola $nameUser, mi nombre es $name y soy el conductor que aceptó tu solicitud.';

    final whatsappLink = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeQueryComponent(message)}');

    try {
      await launchUrl(whatsappLink);
    } catch (e) {
      if(context.mounted){
        showNoWhatsAppInstalledDialog(context);
      }
    }
  }

  void showNoWhatsAppInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WhatsApp no instalado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          content: const Text('No tienes WhatsApp en tu dispositivo. Instálalo e intenta de nuevo'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar', style: TextStyle(color: negro, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  void makePhoneCall(String phoneNumber) async {
    final phoneCallUrl = 'tel:$phoneNumber';

    try {
      await launch(phoneCallUrl);
    } catch (e) {
      if (kDebugMode) {
        print('No se pudo realizar la llamada: $e');
      }
    }
  }
}
