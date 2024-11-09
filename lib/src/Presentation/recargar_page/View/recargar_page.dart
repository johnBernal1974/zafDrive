import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/prices_provider.dart';
import '../../../colors/colors.dart';
import '../../../models/prices.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../../contactanos_page/contactanos_controller/contactanos_controller.dart';

class RecargarPage extends StatefulWidget {
  const RecargarPage({super.key});

  @override
  State<RecargarPage> createState() => _RecargarPageState();
}

class _RecargarPageState extends State<RecargarPage> {

  String? numeroDeRecargas;
  String? whatsAppParaRecargas;
  late ContactanosController _controller;
  late PricesProvider _pricesProvider;

  // Método para obtener el número de WhatsApp desde Firestore
  void fetchWhatsAppNumber() async {
    try {
      // Cambié la consulta para acceder directamente al documento 'info' y al campo 'whatsappRecargas'
      var docSnapshot = await FirebaseFirestore.instance
          .collection('Prices') // Colección 'Prices'
          .doc('info') // Documento 'info'
          .get(); // Obtener el documento 'info'

      if (docSnapshot.exists) {
        // Acceder al campo 'numero_cuenta_recargas' que contiene el número
        var numeroCuentaRecargas = docSnapshot['numero_cuenta_recargas'];
        var whatsappParaRecargas = docSnapshot['whatsappRecargas'];

        if (numeroCuentaRecargas != null) {
          setState(() {
            numeroDeRecargas = numeroCuentaRecargas; // Asignar el número de WhatsApp
            whatsAppParaRecargas = whatsappParaRecargas; // Asignar el número de WhatsApp
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener el número de WhatsApp: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ContactanosController();
    _pricesProvider = PricesProvider();
    fetchWhatsAppNumber(); // Cargar el número de WhatsApp al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
          text: "Recargar",
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: negro,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Instrucciones para realizar la recarga:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: negro,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Image.asset("assets/images/logo_nequi.png", width: 70),
                const SizedBox(width: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Has la recarga al número"),
                    Text(numeroDeRecargas ?? "", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),),
                  ],
                )
              ],
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 10),
            if (numeroDeRecargas != null)
              ...[

                GestureDetector(
                  onTap: (){
                    //_openWhatsApp(context);
                  },
                  child: Row(
                    children: [
                      Image.asset("assets/images/icono_whatsapp.png", width: 70),
                      const SizedBox(height: 25), // Espacio entre la imagen y el texto
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,  // Centra verticalmente dentro de su contenedor
                        crossAxisAlignment: CrossAxisAlignment.center,  // Centra horizontalmente dentro de su contenedor
                        children: [
                          const Text("Envía el comprobante al:", textAlign: TextAlign.center),  // Centra el texto
                          Text(
                            whatsAppParaRecargas ?? "",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                            textAlign: TextAlign.center,  // Centra el texto
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
               const SizedBox(height: 25),
               const Text("* Información Importante*", style: TextStyle(
                 fontSize: 20, fontWeight: FontWeight.bold
               )),
                const SizedBox(height: 5),
                const Text("En el mensaje debes colocar:", style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500
                ),),
                const Text("* Nombre y apellido.", style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500
                ),),
                const Text("* Placa del vehículo o la motocicleta.", style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500
                ),)
              ]
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _openWhatsApp(BuildContext context) async {
    String? phoneNumber = whatsAppParaRecargas.toString();
    String? name = _controller.driver?.the01Nombres.toString();
    String? apellidos = _controller.driver?.the02Apellidos.toString();
    String? placa = _controller.driver?.the18Placa.toString();
    String message = 'Hola Zafiro, mi nombre es $name $apellidos y hare la recarga del vehículo o moto de placa: $placa.';
    final whatsappLink = Uri.parse('whatsapp://send?phone=+57$phoneNumber&text=${Uri.encodeQueryComponent(message)}');
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
          content: const Text('No tienes WhatsApp en tu dispositivo. Instálalo e intenta de nuevo', style: TextStyle(
              fontSize: 14
          ),),
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

  void obtenerDatosPrice() async {
    try {
      Price price = await _pricesProvider.getAll();
      // Convertir a double explícitamente si es necesario
      whatsAppParaRecargas = price.theCelularAtencionConductores;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo los datos: $e');
      }
    }
  }
}
