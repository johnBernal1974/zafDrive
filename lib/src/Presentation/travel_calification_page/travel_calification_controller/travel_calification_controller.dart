

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:zafiro_conductor/providers/travel_history_provider.dart';
import 'package:zafiro_conductor/src/models/travelHistory.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/driver_provider.dart';
import '../../../models/driver.dart';

class TravelCalificationController{

  late BuildContext context;
  late Function refresh;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String? idTravelHistory;
  double? calification;
  int? saldoActual;

  late TravelHistoryProvider _travelHistoryProvider;
  late DriverProvider _driverProvider;
  late MyAuthProvider _authProvider;
  TravelHistory? travelHistory;

  //Para verificacion de internet
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;


  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    _driverProvider = DriverProvider();
    _authProvider = MyAuthProvider();
    idTravelHistory = ModalRoute.of(context)?.settings.arguments as String;
    await checkConnectionAndShowSnackbar();
    getTravelHistory ();
    getSaldoRecarga();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
    });
  }

  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowSnackbar(context, () {
      refresh();  // Llama al método de refresh si es necesario
    });
  }

  Future<void> calificate() async {
    if (calification == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor calificar al usuario.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (calification == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La calificación mínima es 1.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Actualizar la calificación en el historial de viajes
    Map<String, dynamic> data = {
      'calificacionAlCliente': calification,
    };
    await _travelHistoryProvider.update(data, idTravelHistory!);
    travelHistory = await _travelHistoryProvider.getById(idTravelHistory!);
    if (travelHistory == null) {
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el cliente para calificar.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    String idCliente = travelHistory!.idClient;
    Map<String, dynamic> ratingData = {
      'idConductor': _authProvider.getUser()!.uid, // El ID del conductor
      'idTravelHistory': idTravelHistory,
      'calificacion': calification,
      'fecha': DateTime.now(),
    };
    await FirebaseFirestore.instance
        .collection('Clients')
        .doc(idCliente)
        .collection('ratings')
        .add(ratingData);
    // Mantener la lógica existente para verificar el saldo y redirigir al conductor
    if (saldoActual! <= 0) {
      if(context.mounted){
        Navigator.pushNamedAndRemoveUntil(context, 'antes_iniciar', (route) => false);
      }
    } else {
      if(context.mounted){
        Navigator.pushNamedAndRemoveUntil(context, 'map_driver', (route) => false);
      }
    }
  }

  void getTravelHistory() async {
    travelHistory = await _travelHistoryProvider.getById(idTravelHistory!);
    refresh();
  }

  void getSaldoRecarga() async {
    Driver? driver;
    driver = await _driverProvider.getById(_authProvider.getUser()!.uid);
    saldoActual = driver?.the32SaldoRecarga;
  }


}

