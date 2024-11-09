
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/prices_provider.dart';
import '../../../models/driver.dart';
import '../../../models/prices.dart';

class ContactanosController{
  late BuildContext context;

  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSuscription;
  late PricesProvider _pricesProvider;
  Driver? driver;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  String? whatsappAtencionConductor;
  String? celularAtencionConductor;

  Future<void> init (BuildContext context) async {
    this.context = context;
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _pricesProvider = PricesProvider();
    getDrivertInfo();
    obtenerDatosPrice();

  }

  void dispose(){
    _driverInfoSuscription.cancel();
  }

  void getDrivertInfo(){Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser()!.uid);
  _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data() as Map<String, dynamic>);
    });
  }

  void obtenerDatosPrice() async {
    try {
      Price price = await _pricesProvider.getAll();
      // Convertir a double explícitamente si es necesario
      whatsappAtencionConductor = price.theCelularAtencionConductores;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo los datos: $e');
      }
    }
  }
}