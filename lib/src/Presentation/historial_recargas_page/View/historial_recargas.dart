import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class HistorialRecargasPage extends StatefulWidget {
  const HistorialRecargasPage({super.key});

  @override
  State<HistorialRecargasPage> createState() => _HistorialRecargasPageState();
}

class _HistorialRecargasPageState extends State<HistorialRecargasPage> {
  List<Map<String, dynamic>> recargas = []; // Lista para almacenar las recargas

  @override
  void initState() {
    super.initState();
    _cargarHistorialRecargas();
  }

  Future<String> obtenerConductorId() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No hay usuario autenticado.");
      }

      // Consultar Firestore para obtener el id_conductor relacionado con el usuario
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Drivers') // Cambia a tu colección de conductores
          .doc(user.uid) // Asumiendo que usas el UID como ID del documento
          .get();

      if (!snapshot.exists) {
        throw Exception("No se encontró el documento del conductor.");
      }

      // Extraer el id_conductor del documento
      String conductorId = snapshot.get('id');
      return conductorId;
    } catch (e) {
      print("Error al obtener el ID del conductor: $e");
      throw e;
    }
  }

  Future<void> _cargarHistorialRecargas() async {
    try {
      String conductorId = await obtenerConductorId();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recargas')
          .where('idDriver', isEqualTo: conductorId) // Filtra por el ID del conductor
          .orderBy('fecha_hora', descending: true) // Ordena por fecha más reciente
          .get();

      // Mapea los documentos a una lista
      setState(() {
        recargas = snapshot.docs.map((doc) {
          return {
            'fecha_hora': doc['fecha_hora'] ?? '',
            'saldo_anterior': doc['1saldo_anterior'] ?? 0.0, // Ensuring it's a double
            'nueva_recarga': doc['2nueva_recarga'] ?? 0.0, // Ensuring it's a double
            'saldo-total': doc['3saldo_total'] ?? 0.0, // Ensuring it's a double
          };
        }).toList();
      });
    } catch (e) {
      print("Error al cargar recargas: $e");
    }
  }

  // Function to format currency with $ symbol at the beginning and no decimals
  String formatCurrency(double value) {
    final format = NumberFormat.simpleCurrency(locale: 'en_US'); // Use the US locale for dollar formatting
    String formattedValue = format.format(value);
    return formattedValue.replaceAll(RegExp(r'\.00'), '').replaceAll(RegExp(r'€'), '\$'); // Remove decimals and replace €
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
          text: "Historial de Recargas",
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: negro,
        ),
      ),
      body: recargas.isEmpty
          ? const Center(
        child: Text(
          "No hay recargas registradas",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      )
          : ListView.builder(
        itemCount: recargas.length,
        itemBuilder: (context, index) {
          final recarga = recargas[index];
          DateTime fechaHora = (recarga['fecha_hora'] as Timestamp).toDate(); // Convert timestamp to DateTime
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Fecha:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm a').format(fechaHora),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Saldo Anterior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saldo Anterior:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                      Text(
                        formatCurrency(recarga['saldo_anterior'].toDouble()),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Recarga Actual
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recarga actual:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                      Text(
                        formatCurrency(recarga['nueva_recarga'].toDouble()),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Saldo Final
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saldo final:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                      Text(
                        formatCurrency(recarga['saldo-total'].toDouble()),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1),
                      ),
                    ],
                  ),
                ],
              ),

            ),
          );
        },
      ),
    );
  }
}
