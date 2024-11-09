import 'package:flutter/material.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class HistorialRecargasPage extends StatefulWidget {
  const HistorialRecargasPage({super.key});

  @override
  State<HistorialRecargasPage> createState() => _HistorialRecargasPageState();
}

class _HistorialRecargasPageState extends State<HistorialRecargasPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "Historial de Recargas",
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: negro
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: const Column(
          children: [
            Text("Historial de Recargas"),
          ],
       )
      ),
    );
  }

}
