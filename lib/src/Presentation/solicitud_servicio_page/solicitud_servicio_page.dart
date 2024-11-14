import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:zafiro_conductores/src/Presentation/solicitud_servicio_page/solicitud_servicio_controller/solicitud_servicio_controller.dart';
import 'package:zafiro_conductores/src/colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';

class SolicitudDeServicioPage extends StatefulWidget {
  const SolicitudDeServicioPage({super.key});

  @override
  State<SolicitudDeServicioPage> createState() => _SolicitudDeServicioPageState();
}

class _SolicitudDeServicioPageState extends State<SolicitudDeServicioPage> {
  late SolicitudServicioController _controller;
  String? tarifaFormatted;

  @override
  void initState() {
    super.initState();
    _controller = SolicitudServicioController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      formateartarifa();
      _controller.soundNotificacionDeServicio('assets/audio/ring_final.mp3');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tituloNotificacion(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _infoOrigenDestino(),
                  const SizedBox(height: 30),
                  _tarifa(),
                  const SizedBox(height: 20),
                  _apuntesDelUsuario(),
                ],
              ),
            ),
            _botones(context),
          ],
        ),
      ),
    );
  }

  Widget _tituloNotificacion() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(70),
          bottomLeft: Radius.circular(70),
        ),
        color: primary,
        boxShadow: [
          BoxShadow(
            color: gris,
            offset: Offset(5, 5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Solicitud de Servicio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: blanco),
          ),
          _contador(),
        ],
      ),
    );
  }

  Widget _infoOrigenDestino() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('LUGAR DE RECOGIDA', 'assets/images/posicion_usuario_negra.png'),
        _infoText(_controller.from),
        _infoRow('0.8 kms', '2 minutos'),
        const Divider(color: grisMedio, height: 30, indent: 2, endIndent: 2),
        _sectionHeader('DESTINO', 'assets/images/posicion_destino.png'),
        _infoText(_controller.to),
      ],
    );
  }

  Widget _sectionHeader(String title, String assetPath) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Image.asset(assetPath, height: 20, width: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: negro),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String? text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text ?? '',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: negro),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _infoRow(String distance, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoIconText(Icons.map_outlined, distance),
        _infoIconText(Icons.timer_outlined, time),
      ],
    );
  }

  Widget _infoIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: turquesa, size: 20),
        const SizedBox(width: 5),
        headerText(text: text, fontSize: 14, color: gris, fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tarifa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tarifaColumn('Tarifa', tarifaFormatted),
          _tarifaColumn('Servicio', _controller.tipoServicio),
        ],
      ),
    );
  }

  Widget _tarifaColumn(String title, String? value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: negro)),
        Text(value ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _contador() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: Text(
        _controller.seconds.toString(),
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: blanco),
      ),
    );
  }

  Widget _botones(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: _button(
              'Aceptar',
              Colors.green,
              18,
              buttonWidth,
              _controller.acceptTravel,
              Icons.double_arrow,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: _button(
              'Rechazar',
              Colors.redAccent,
              12,
              buttonWidth,
              _controller.cancelTravel,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String text, Color color, double fontSize, double width, VoidCallback onPressed, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shadowColor: gris,
        elevation: 6,
        minimumSize: Size(width, 50),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: blanco),
      label: Text(
        text,
        style: TextStyle(color: blanco, fontSize: fontSize),
      ),
    );
  }


  Widget _apuntesDelUsuario() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: blanco,
        boxShadow: [
          BoxShadow(
            color: gris.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apuntes del Usuario', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 10),
          Text(
            _controller.apuntesUsuario ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void formateartarifa() {
    String tarifa = _controller.tarifa ?? '';
    double tarifaDouble = double.tryParse(tarifa) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,###', 'es_ES');
    tarifaFormatted = '\$ ${formatter.format(tarifaDouble)}';
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void refresh() {
    if(mounted){
      setState(() {});
    }
  }
}
