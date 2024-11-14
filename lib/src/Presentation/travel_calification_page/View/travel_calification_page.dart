import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../travel_calification_controller/travel_calification_controller.dart';

class TravelCalificationPage extends StatefulWidget {
  const TravelCalificationPage({super.key});

  @override
  State<TravelCalificationPage> createState() => _TravelCalificationPageState();
}

class _TravelCalificationPageState extends State<TravelCalificationPage> {

  late TravelCalificationController _controller;
  String? tarifaFormatted;
  final ConnectionService connectionService = ConnectionService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TravelCalificationController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _controller.key,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Asegura que la columna se extienda horizontalmente
          children: [
            Expanded(
              child: ListView(
                children: [
                  _tituloNotificacion(),
                  const SizedBox(height: 30),
                  _infoOrigenDestino(),
                  const SizedBox(height: 30),
                  _tarifa(),
                  const SizedBox(height: 30),
                  _subtituloCuantasEstrellas(),
                  const SizedBox(height: 10),
                  _ratingBar ()
                ],
              ),
            ),
            _botones(), // Mueve los botones fuera del Expanded
          ],
        ),
      ),
    );
  }

  Widget _subtituloCuantasEstrellas() {
    return Container(
      alignment: Alignment.center,
      child: const Text('¿Cuántas estrellas le das al usuario?', style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold
      ),
      ),
    );
  }

  Widget _tituloNotificacion(){
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70),
              bottomLeft: Radius.circular(70)),
          gradient: LinearGradient(
            colors: [
              primary, // Color existente
              turquesa,   // Color turquesa
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(
            color: gris,
            offset: Offset(5,5),
            blurRadius: 5,
          )]),
      child: const Text('Servicio Finalizado', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: blanco
          ),
      textAlign: TextAlign.center,)
    );
  }

  Widget _infoOrigenDestino(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70),
                topRight: Radius.circular(70)),
            color: blanco,
          ),
          child: Row(
            children: [
              Image.asset('assets/images/marker_inicio.png', height: 18, width: 18),
              const SizedBox(width: 10,),
              const Text('Origen', style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: negro)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 35, right: 15, top: 5),
          child:Text(_controller.travelHistory?.from ?? '', style: const TextStyle(
              fontWeight: FontWeight.w700,fontSize: 13, color: negroLetras), maxLines: 2),
        ),
        const SizedBox(height: 10),
        const Divider(color: grisMedio,height: 1,indent: 2, endIndent: 2,),
        const SizedBox(height: 15),
        Container(
          width: 100,
          padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(70),
                topRight: Radius.circular(70)),
            color: blanco,
          ),
          child: Row(
            children: [
              Image.asset('assets/images/marker_destino.png', height: 18, width: 18),
              const SizedBox(width: 10,),
              const Text('Destino', style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: negro)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 35, right: 15, top: 5),
          child:Text(_controller.travelHistory?.to ?? '', style: const TextStyle(
              fontWeight: FontWeight.w700,fontSize: 13, color: negroLetras), maxLines: 2),
        ),
        const SizedBox(height: 15),
        const Divider(color: grisMedio,height: 1,indent: 2, endIndent: 2)
      ],
    );
  }

  void formateartarifa() {
    String tarifa = _controller.travelHistory?.tarifa.toString() ?? '';
    double tarifaDouble = double.tryParse(tarifa) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,###', 'es_ES');
    tarifaFormatted = '\$ ${formatter.format(tarifaDouble)}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _ratingBar () {
    return Center(
      child: RatingBar.builder(
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          initialRating: 0,
          direction: Axis.horizontal,
          itemSize: 35,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4),
          allowHalfRating: true,
          unratedColor: grisMedio,
          onRatingUpdate: (ratingBar) {
            _controller.calification = ratingBar;
        }
      )
    );
  }

  Widget _tarifa (){
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Column(
            children: [
              const Text('Tarifa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: negro)),
              Text(tarifaFormatted ?? '', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            ],
          ),
    );
  }

  Widget _botones() {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 2, // Proporción del primer botón
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shadowColor: gris,
                elevation: 6,
              ),
              onPressed: isLoading
                  ? null // Desactiva el botón si está cargando
                  : () async {
                // Verificar conexión a Internet antes de ejecutar la acción
                bool hasConnection = await connectionService.hasInternetConnection();
                if (hasConnection) {
                  setState(() {
                    isLoading = true; // Muestra el indicador de carga
                  });
                  await _controller.calificate();
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  alertSinInternet();
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator(
                color: blanco, // Color del indicador
              )
                  : const Text(
                'Calificar Usuario',
                style: TextStyle(color: blanco, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future alertSinInternet (){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void refresh(){
    if(mounted){
      setState(() {
        formateartarifa();
      });
    }
  }

}
