
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/driver_provider.dart';
import '../../../models/driver.dart';

class AntesIniciarController{
  late BuildContext context;
  late Function refresh;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;// ok
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSuscription;
  Driver? driver;
  int saldoRecargaInt = 0;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  Timer? _notificationPermissionCheckTimer;
  Timer? _notificationPermissionDeniedPermanentlyCheckTimer;

  //Para verificacion de internet
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false; //**para validar el estado de conexion a internet
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;  // Suscripción para escuchar cambios en conectividad


  Future<void> init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _driverProvider = DriverProvider();//ok
    _authProvider = MyAuthProvider();

    // Verificar la conexión a Internet al iniciar el controlador
    await checkConnectionAndShowSnackbar();
    getDriverInfo();
    // Escuchar los cambios de conectividad en tiempo real
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
    });
  }

  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowSnackbar(context, () {
      refresh();
    });
  }

  void dispose(){
    _driverInfoSuscription.cancel();
    _notificationPermissionCheckTimer?.cancel();
    _notificationPermissionDeniedPermanentlyCheckTimer?.cancel();
    _connectivitySubscription?.cancel();

  }

  void opendrawer(){
    key.currentState?.openDrawer();
  }

  void getDriverInfo(){    //ok
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver.fromJson(document.data() as Map<String, dynamic>);
      refresh();
    });
  }

  void requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print("Permiso de notificaciones otorgado");
      }
    } else if (status.isDenied) {
      // Permiso denegado, mostrar diálogo hasta que el usuario lo conceda
      showNotificationPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      // Permiso denegado permanentemente, informar al usuario que debe habilitarlo manualmente
      showPermanentlyDeniedNotificationDialog();
    }
  }

  void showNotificationPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        // Comenzar a revisar el estado del permiso de notificaciones cada 2 segundos
        _notificationPermissionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
          var status = await Permission.notification.status;
          if (status.isGranted) {
           if(context.mounted){
             Navigator.of(context).pop();
           }
            timer.cancel();
          }
        });

        return AlertDialog(
          title: const Text("Permiso de Notificaciones"),
          content: const Text("Para recibir solicitudes de servicios es indispensable permitir que Tay-rona envíe notificaciones."),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Configurar"),
              onPressed: () {
                requestNotificationPermission(); // Volver a solicitar el permiso
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cancelar el temporizador si el diálogo se cierra manualmente
      _notificationPermissionCheckTimer?.cancel();
    });
  }

  void showPermanentlyDeniedNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        // Iniciar el temporizador para verificar el estado del permiso
        _notificationPermissionDeniedPermanentlyCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          var status = await Permission.notification.status; // Verificar el estado del permiso
          if (status.isGranted) {
            // Si el permiso es concedido, cerrar el diálogo
            if(context.mounted){
              Navigator.of(context).pop();
            }
            timer.cancel(); // Cancelar el temporizador
          }
        });

        return AlertDialog(
          contentPadding: const EdgeInsets.all(20), // Padding para el contenido del diálogo
          title: Column(
            children: [
              Icon(
                Icons.notifications,
                color: Theme.of(context).primaryColor, // Color del ícono basado en el color primario de la app
                size: 40, // Tamaño del ícono
              ),
              const SizedBox(height: 10), // Espacio entre el ícono y el título
              const Text("Permiso de \nNotificaciones", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              textAlign: TextAlign.center,),
            ],
          ),
          content: const Text("Para recibir solicitudes de servicios es indispensable permitir que Tay-rona envíe notificaciones."),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Ir a Configuración"),
              onPressed: () {
                openAppSettings(); // Abre la configuración de la app para que el usuario pueda habilitar manualmente
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cancelar el temporizador si el diálogo se cierra manualmente
      _notificationPermissionDeniedPermanentlyCheckTimer?.cancel();
    });
  }

  void goToMapDriver(){
    Navigator.pushNamedAndRemoveUntil(context, "map_driver", (route) => false);
  }
  void goToHistorialViajes(){
    Navigator.pushNamed(context, "historial_viajes");
  }

  void goToHistorialRecargas(){
    Navigator.pushNamed(context, "historial_recargas");
  }

  void goToRecargar(){
    Navigator.pushNamed(context, "recargar");
  }

  void goToElegirNavegador(){
    Navigator.pushNamed(context, "elegir_navegador");
  }

  void goToPoliticasDePrivacidad(){
    Navigator.pushNamed(context, "politicas_de_privacidad");
  }

  void goToPermisosDeUbicacion(){
    Navigator.pushNamed(context, "permisos_de_ubicacion");
  }

  void goToContactanos(){
    Navigator.pushNamed(context, "contactanos");
  }

  void goToCompartirAplicacion(){
    Navigator.pushNamed(context, "compartir_aplicacion");
  }

  void goToProfile(){
    Navigator.pushNamed(context, "profile");
  }
  void goToEliminarCuenta(){
    Navigator.pushNamed(context, "eliminar_cuenta");
  }

}