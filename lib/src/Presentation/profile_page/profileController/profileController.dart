
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../models/driver.dart';

class ProfileController {
  late BuildContext context;
  late Function refresh;
  Driver? driver;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  bool isMoto = false;
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSubscription;
  double promedio = 0;
  String idDriver = '';

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();

    // Obtener el ID del conductor
    obtenerDriverId();

    getDriverInfo();
    // Asegúrate de que el ID del conductor no esté vacío antes de llamar a este método
    if (idDriver.isNotEmpty) {
      getDriverRatingAverage(idDriver);
    }
  }

  void dispose() {
    _driverInfoSubscription.cancel();
  }

  void obtenerDriverId() {
    idDriver = _authProvider.getUser()!.uid;
  }

  void getDriverInfo() {
    Stream<DocumentSnapshot> driverStream =
    _driverProvider.getByIdStream(idDriver);
    _driverInfoSubscription = driverStream.listen(
          (DocumentSnapshot document) {
        if (document.exists) {
          driver = Driver.fromJson(document.data() as Map<String, dynamic>);
          obtenerRol();  // Llama a obtenerRol después de actualizar el conductor
          refresh();
        } else {
          if (kDebugMode) {
            print('El documento del conductor no existe.');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error al obtener el documento del conductor: $error');
        }
      },
    );
  }

  Future<double> getDriverRatingAverage(String idConductor) async {
    try {
      // Obtener todas las calificaciones del conductor desde la subcolección "ratings"
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(idConductor)
          .collection('ratings')
          .get();
      if (ratingsSnapshot.docs.isEmpty) {
        return 0.0;
      }
      // Calcular el total sumando todas las calificaciones
      double total = 0.0;
      for (var doc in ratingsSnapshot.docs) {
        total += doc['calificacion'];
      }
      // Calcular el promedio dividiendo el total por el número de calificaciones
      promedio = total / ratingsSnapshot.docs.length;
      return promedio;  // Retorna el promedio de calificaciones
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener el promedio de calificaciones: $e");
      }
      return 0.0;
    }
  }

  void obtenerRol() async {
    String? rol = driver?.rol.toString();
    if (rol != null) {
      isMoto = (rol == 'moto');
    }
  }
}



