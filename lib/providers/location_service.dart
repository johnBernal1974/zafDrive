import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workmanager/workmanager.dart';

class LocationService {
  Stream<LatLng>? locationStream;

  // Método para iniciar la escucha de cambios en la ubicación
  void startListeningToLocation() {
    // Configuración de la ubicación
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // Precisión alta
      distanceFilter: 10, // Actualiza cada 100 metros de movimiento
    );

    // Escuchar los cambios de ubicación
    locationStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position position) {
      return LatLng(position.latitude, position.longitude);
    });
  }

  // Método para detener la escucha de cambios en la ubicación
  void stopListeningToLocation() {
    locationStream = null;
    Workmanager().cancelAll();
  }

  // Método para obtener la ubicación actual en el momento de la llamada
  Future<LatLng> getCurrentDriverPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Esto sigue funcionando
    );
    return LatLng(position.latitude, position.longitude);
  }
}
