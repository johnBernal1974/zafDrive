import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> locationUpdateTask() async {
  print("LocationUpdateWorker: Ejecutando tarea de actualización de ubicación");

  try {
    // Inicializar Firebase en el contexto del worker
    await Firebase.initializeApp();
    print("Firebase initialized");

    // Verificar si el usuario está autenticado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Usuario autenticado: ${user.uid}");

      // Verificar y solicitar permisos de ubicación
      await _checkLocationPermission();

      // Obtener la ubicación actual del conductor
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Ubicación obtenida: ${position.latitude}, ${position.longitude}");

      // Obtener el estado del conductor desde Firestore
      String status = await _getStatus(user.uid);
      print("Estado del conductor: $status");

      // Actualizar la ubicación del conductor en Firestore según su estado
      if (status == 'driver_available') {
        await GeofireProvider().create(user.uid, position.latitude, position.longitude);
        print("driver_available: Ubicación actualizada en Firestore");
      } else if (status == 'driver_working') {
        await GeofireProvider().createWorking(user.uid, position.latitude, position.longitude);
        print("driver_working: Ubicación actualizada en Firestore");
      }

      print("Ubicación actualizada en Firestore: ${position.latitude}, ${position.longitude}");
    } else {
      print("Usuario no autenticado. No se puede actualizar la ubicación.");
    }
  } catch (e) {
    print("Error al actualizar la ubicación en Firestore: $e");
  }
}

Future<void> _checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    // Manejar el caso en que el usuario ha denegado permanentemente el acceso a la ubicación
    print("Permiso de ubicación denegado permanentemente.");
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await locationUpdateTask(); // Asegurarse de que la función es esperada
    return Future.value(true);
  });
}

void registerLocationUpdateTask() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "locationUpdateTask",
    "locationUpdateTask",
    frequency: const Duration(minutes: 15), // Cambiado a 15 minutos por restricciones de Android
  );
}

class GeofireProvider {
  late CollectionReference _ref;
  late GeoFlutterFire _geo;

  GeofireProvider() {
    _ref = FirebaseFirestore.instance.collection('Locations');
    _geo = GeoFlutterFire();
  }

  Future<void> create(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({
      'status': 'driver_available',
      'position': myLocation.data,
    }, SetOptions(merge: true)); // Usar merge: true
  }

  Future<void> createWorking(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({
      'status': 'driver_working',
      'position': myLocation.data,
    }, SetOptions(merge: true)); // Usar merge: true
  }
}

Future<String> _getStatus(String userId) async {
  try {
    // Obtener la referencia al documento del conductor en Firestore
    DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance.collection('Locations').doc(userId).get();

    // Verificar si el documento existe y contiene el campo 'status'
    if (locationSnapshot.exists && locationSnapshot.data() != null) {
      // Convertir los datos a un Map<String, dynamic>
      Map<String, dynamic> data = locationSnapshot.data() as Map<String, dynamic>;

      // Verificar si el campo 'status' está presente en los datos
      if (data.containsKey('status')) {
        // Obtener y devolver el estado del conductor
        String status = data['status'];
        print('El estado del conductor es: $status');
        return status;
      }
    }

    // Si el documento no existe o no contiene el campo 'status', devuelve un estado predeterminado
    return 'driver_available'; // Puedes cambiar esto según tus necesidades
  } catch (e) {
    // Manejar cualquier error que pueda ocurrir durante la obtención del estado del conductor
    print("Error al obtener el estado del conductor: $e");
    return 'driver_available'; // Devuelve un estado predeterminado en caso de error
  }
}
