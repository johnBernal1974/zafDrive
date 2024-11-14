
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zafiro_conductores/src/Presentation/map_driver_page/View/map_driver_page.dart';
import '../../../../providers/auth_provider.dart';
import 'package:zafiro_conductores/src/models/client.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../providers/client_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/geofire_provider.dart';
import '../../../../providers/travel_info_provider.dart';

class SolicitudServicioController{

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String? from;
  String? to;
  String? idClient;
  String? tarifa;
  String? tipoServicio;
  String? apuntesUsuario;
  Timer? _timer;
  int seconds = 15;

  late TravelInfoProvider _travelInfoProvider;
  late MyAuthProvider _authProvider;
  late ClientProvider _clientProvider;
  late GeofireProvider _geofireProvider;
  late DriverProvider _driverProvider;
  late AudioPlayer _player;
  Client? client;


  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _clientProvider = ClientProvider();
    _authProvider = MyAuthProvider();
    _travelInfoProvider = TravelInfoProvider();
    _geofireProvider = GeofireProvider();
    _driverProvider = DriverProvider();

    Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    from = arguments['origin'];
    to = arguments['destination'];
    idClient = arguments['idClient'];
    tarifa = arguments['tarifa'];
    tipoServicio = arguments['tipo_servicio'];
    apuntesUsuario = arguments['apuntes_usuario'];
    getClientInfo();
    startTimer();

  }

  void getClientInfo() async {
    client = await _clientProvider.getById(idClient!);
    refresh();
  }

  void acceptTravel (){
    stopSoundNotificacionDeServicio();
    Map<String, dynamic> data = {
      'idDriver': _authProvider.getUser()!.uid,
      'status': 'accepted',
    };
    _travelInfoProvider.update(data, idClient!);
    _geofireProvider.delete(_authProvider.getUser()!.uid);
    actualizarEstadoIsWorkingTrue ();
    guardarUltimoCliente();
    _driverProvider.updateIsActiveAFalse(_authProvider.getUser()!.uid);

    Navigator.of(context).pushReplacementNamed(
      'travel_map_page',
      arguments: {
        'documentId': idClient,
      },
    );
    _timer?.cancel();
  }



  void cancelTravel () {
    stopSoundNotificacionDeServicio();
    Map<String, dynamic> data = {
      'status': 'no_accepted',
    };

    _travelInfoProvider.update(data, idClient!);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MapDriverPage()),
          (route) => false,
    );
    _timer?.cancel();
  }

  void dispose (){
    _timer?.cancel();

  }

  void startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds = seconds - 1;
      refresh();
      if(seconds == 0){
        cancelTravel();
      }
    });
  }



  void soundNotificacionDeServicio(String audioPath) async {
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/ring_final.mp3');
    await _player.play();
  }

  void stopSoundNotificacionDeServicio() async {
    if (_player.playing) {
      await _player.stop();
    }
  }

  void actualizarEstadoIsWorkingTrue () async {
    Map<String, dynamic> data = {
      '00_is_working': true};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();

  }


  void guardarUltimoCliente () async {
    Map<String, dynamic> data = {
      '00_ultimo_cliente':idClient};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

}

