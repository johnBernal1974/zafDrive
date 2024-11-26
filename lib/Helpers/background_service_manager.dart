import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundServiceManager {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  // Inicializar el servicio
  Future<void> initializeService() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // Iniciar el servicio

  Future<void> startService() async {
    if (!await _service.isRunning()) {
      await _service.startService();
      print("**************************Servicio iniciado correctamente.");
    } else {
      print("******************************El servicio ya está en ejecución.");
    }
  }

  // Detener el servicio
  Future<void> stopService() async {
    if (await _service.isRunning()) {
      // Detener el servicio correctamente
      _service.invoke("stopService");  // No es necesario usar await aquí
      print("*******************Servicio detenido correctamente.");
    } else {
      print("******************El servicio no está corriendo.");
    }
  }

  // Verificar si el servicio está activo
  Future<bool> isServiceRunning() async {
    return await _service.isRunning();
  }
}

// Función para ejecutar cuando se inicia el servicio
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Servicio de ubicación activo",
      content: "Actualizando tu ubicación en segundo plano.",
    );
  }

  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  // Geolocator.getPositionStream().listen((Position position) {
  //   if (kDebugMode) {
  //     print("**********************Nueva posición: ${position.latitude}, ${position.longitude}");
  //   }
  // });
}


// Función para iOS (en caso de usarlo)
bool onIosBackground(ServiceInstance service) {
  debugPrint("Servicio corriendo en segundo plano en iOS");
  return true;
}
