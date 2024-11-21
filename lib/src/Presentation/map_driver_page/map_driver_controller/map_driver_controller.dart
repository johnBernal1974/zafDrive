import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:location/location.dart' as location;

import '../../../../Helpers/LocationPermissionManager.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/driver_provider.dart';
import '../../../../providers/location_service.dart';
import '../../../../providers/prices_provider.dart';
import '../../../../providers/push_notifications_provider.dart';
import '../../../../providers/travel_info_provider.dart';
import '../../../colors/colors.dart';
import '../../../models/driver.dart';
import '../../../models/prices.dart';
import '../../../models/travel_info.dart';
import '../../antes_inicar_page/View/antes_inicar_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zafiro_conductores/utils/utilsMap.dart';
import 'package:zafiro_conductores/providers/geofire_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class DriverMapController{
  late BuildContext context;
  late Function refresh;
  bool isMoto = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
  late AudioPlayer _player;
  String documentId= "";
  double tarifa= 0;
  double? radioBusqueda;
  final String _yourGoogleAPIKey = dotenv.get('API_KEY');


  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(4.8470616, -74.0743461),
    zoom: 20.0,

  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late Position _position;
  late StreamSubscription<Position> _positionStream;
  late BitmapDescriptor markerDriver;
  late BitmapDescriptor markerMotorcycler;
  late BitmapDescriptor markerDefault;
  late GeofireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  bool isConected = true;
  late StreamSubscription<DocumentSnapshot<Object?>> _statusSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSuscription;
  late PushNotificationsProvider _pushNotificationsProvider;
  late TravelInfoProvider _travelInfoProvider;
  late PricesProvider _pricesProvider;
  bool isSoundPlaying = false;
  String? rol = '';

  //Para verificacion de internet
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false; //**para validar el estado de conexion a internet
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;  // Suscripción para escuchar cambios en conectividad
  final locationService = LocationService();



  Driver? driver;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // Inicialización de proveedores
    _geofireProvider = GeofireProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _travelInfoProvider = TravelInfoProvider();
    _pushNotificationsProvider = PushNotificationsProvider();
    _pricesProvider = PricesProvider();

    // Crear imágenes de marcadores de forma asíncrona
    markerDriver = await createMarkerImageFromAssets('assets/images/marcador_carro_azul80px.png');
    markerMotorcycler = await createMarkerImageFromAssets('assets/images/marcador_motos.png');


    // Guardar token y estado de bloqueo (independiente de permisos o ubicación)
    saveToken();
    obtenerStadoBloqueo();

    // Verificación de permisos de ubicación y GPS
    await checkAndRequestLocationPermission();
    checkGPS();

    // Verificación de conexión a Internet y configuración de escucha de cambios
    await checkConnectionAndShowSnackbar();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
      refresh();
    });

    // Obtener información del conductor
    getDriverInfo();

    // Obtener posición actual y configurar la posición inicial de la cámara
    _position = await Geolocator.getCurrentPosition();
    initialPosition = CameraPosition(
      target: LatLng(_position.latitude, _position.longitude),
      zoom: 20.0,
    );

    // Obtener datos de precios
    obtenerDatosPrice();

  }

  Future<void> checkAndRequestLocationPermission() async {
    await LocationPermissionManager.checkAndRequestLocationPermission(context);
  }
  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowSnackbar(context, () {
      refresh();  // Llama al método de refresh si es necesario
    });
  }

  void obtenerDatosPrice() async {
    try {
      Price price = await _pricesProvider.getAll();
      radioBusqueda = price.theRadioBusqueda;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo los datos: $e');
      }
    }
  }

  void getDriverInfo(){
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver?.fromJson(document.data() as Map<String, dynamic>);
      verificarsaldo();
      obtenerRol();
      refresh();
    });
  }

  void obtenerStadoBloqueo(){
    if(driver?.verificacionStatus == "bloqueado"){
      Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
    }
  }

  @override
  void dispose(){
    _positionStream.cancel();
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
    _connectivitySubscription?.cancel();
  }

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
  }

  void saveLocation() async {
    User? user = _authProvider.getUser();
    if (user != null) {
      await _geofireProvider.create(
          user.uid,
          _position.latitude,
          _position.longitude);
    } else {
      if (kDebugMode) {
        print("El usuario es nulo************");
      }

    }
  }

  void saveToken(){
    _pushNotificationsProvider.saveToken(_authProvider.getUser()!.uid);
  }

  void connect(BuildContext context) {
    if (isConected) {
      // Actualiza la ubicación si es necesario
      disconnect();
      Navigator.pushNamedAndRemoveUntil(context, 'antes_iniciar', (route) => false);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(
                  color: negroLetras,
                  strokeWidth: 5
              ),
            ),
          );
        },
      );
      updateLocation();
      // Aquí puedes cerrar el diálogo manualmente después de que se actualice la ubicación
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Cierra el dialogo después de un retraso
      });
    }
  }

  void disconnect(){
    _positionStream.cancel();
    _geofireProvider.delete(_authProvider.getUser()!.uid);
    _soundDesonectado('assets/audio/te_has_desconectado.mp3');
    locationService.stopListeningToLocation();


  }

  void checkIfIsConnected(){
    Stream<DocumentSnapshot> status=
    _geofireProvider.getLocationByIdStream(_authProvider.getUser()!.uid);
    _statusSuscription = status.listen((DocumentSnapshot document) {
      if(document.exists){
        isConected = true;
        _driverProvider.updateIsActiveATrue(_authProvider.getUser()!.uid);
      }else{
        isConected = false;
        _driverProvider.updateIsActiveAFalse(_authProvider.getUser()!.uid);
      }
      //refresh();
    });

  }

  void updateLocation() async {
    try {
      final stopwatch = Stopwatch()..start();
      await _determinePosition();
      _position = (await Geolocator.getLastKnownPosition())!;
      centerPosition();
      saveLocation();
      refresh();

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen((Position position) {
        _position = position;
        if (rol == 'moto') {
          addMarker(
            'driver',
            _position.latitude,
            _position.longitude,
            "Tu posición", "",
            markerMotorcycler,
          );
        } else {
          addMarker(
            'driver',
            _position.latitude,
            _position.longitude,
            "Tu posición", "",
            markerDriver,
          );
        }

        animateCameraToPosition(_position.latitude, _position.longitude);
        saveLocation();
        refresh();
      });

      _positionStream.onError((error) {
        if (kDebugMode) {
          print('Error en el stream de posición: $error');
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error en la localizacion: $error');
      }
    }
  }


  void centerPosition(){
    animateCameraToPosition (_position.latitude, _position.longitude);

  }

  void checkGPS() async{
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(islocationEnabled){
      updateLocation();
      checkIfIsConnected();
    }
    else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
        checkIfIsConnected();
      }
    }
  }

  void verificarsaldo(){
    int saldo= driver?.the32SaldoRecarga ?? 0;
    if(saldo <= 0){
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const AntesIniciarPage()));
    }
  }

  void opendrawer(){
    key.currentState?.openDrawer();
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

  void goToTravelMapPage(){
    Navigator.pushNamedAndRemoveUntil(
        context,
        'travel_map_page',
            (route) => false,
        arguments: documentId
    );
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future? animateCameraToPosition(double latitude, double longitude)  async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 14

        )));

  }

  Future<BitmapDescriptor> createMarkerImageFromAssets(String path) async {
    ImageConfiguration configuration = const ImageConfiguration();
    BitmapDescriptor bitmapDescriptor=
    await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarker(
      String markerId,
      double lat,
      double lng,
      String title,
      String content,
      BitmapDescriptor iconMarker
      ){
    MarkerId id =MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        rotation: _position.heading
    );

    markers[id] = marker;

  }


  void _soundDesonectado(String audioPath) async {
    _player = AudioPlayer();
    await _player.setAsset('assets/audio/te_has_desconectado.mp3');
    await _player.play();
  }

  void obtenerRol() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Drivers') // Cambia 'drivers' según tu estructura
        .doc(user?.uid)
        .get();

    rol = userDoc.get('rol');
  }


  Stream<List<Map<String, dynamic>>> fetchFilteredRequestsStream() async* {
    try {
      // Verificar si el usuario está autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      locationService.startListeningToLocation();

      // Obtener el rol del conductor desde la base de datos
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Drivers') // Cambia 'drivers' según tu estructura
          .doc(user.uid)
          .get();

      String? rol = userDoc.get('rol');
      if (rol == null) {
        throw Exception('Rol del conductor no encontrado');
      }

      // Obtener las solicitudes con estado "created" de Firestore
      Query requestsQuery = FirebaseFirestore.instance
          .collection('TravelInfo')
          .where('status', isEqualTo: 'created');

      // Si el rol es "carro", aplicar filtro adicional por tipo de servicio
      if (rol == 'carro') {
        requestsQuery = requestsQuery.where('tipoServicio', whereIn: ['Transporte', 'Encomienda']);
      } else {
        requestsQuery = requestsQuery.where('tipoServicio', whereIn: ['Moto', 'Encomienda']);
      }

      // Continuar con la consulta de snapshots
      final requestsCollection = requestsQuery.snapshots();

      // Almacenar IDs de solicitudes visibles para comparación
      List<String> currentRequestIds = [];
      // Almacenar el conteo anterior de solicitudes
      int previousDocumentCount = 0;

      await for (var snapshot in requestsCollection) {
        // Obtener la ubicación actual del conductor
        LatLng driverLocation = await locationService.getCurrentDriverPosition();
        double currentLat = driverLocation.latitude;
        double currentLong = driverLocation.longitude;

        // Lista de solicitudes filtradas por distancia
        List<Map<String, dynamic>> filteredRequests = [];

        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  // Casting explícito
          double requestLat = (data['fromLat'] as num).toDouble();
          double requestLong = (data['fromLng'] as num).toDouble();
          documentId = doc.id;

          // Calcular la distancia entre el conductor y la solicitud
          double distanceInMeters = Geolocator.distanceBetween(currentLat, currentLong, requestLat, requestLong);

          // Obtener tiempo y distancia usando la API
          var apiKey = _yourGoogleAPIKey; // Reemplaza con tu clave API
          var durationAndDistance = await fetchDistanceAndDuration(
              LatLng(currentLat, currentLong), LatLng(requestLat, requestLong), apiKey);

          // Solo añadimos solicitudes que están dentro del rango
          double radioDeBusqueda = radioBusqueda! * 1000; // Radio en metros
          if (distanceInMeters <= radioDeBusqueda) {
            filteredRequests.add({
              'id': documentId,
              'tipoServicio': data['tipoServicio'] ?? 'Tipo de servicio no disponible',
              'from': data['from'] ?? 'Origen no disponible',
              'to': data['to'] ?? 'Destino no disponible',
              'tiempoViaje': durationAndDistance['duration'] ?? 'No disponible',
              'distancia': durationAndDistance['distance'] ?? 'No disponible',
              'tarifa': data['tarifa'] ?? 0,
              'apuntes': data['apuntes'] ?? '',
            });
            currentRequestIds.add(documentId);
          }
        }

        // Filtrar las solicitudes que ya no son visibles
        filteredRequests.removeWhere((request) => !currentRequestIds.contains(request['id']));

        // Actualizar el conteo anterior después de la verificación
        previousDocumentCount = filteredRequests.length;

        // Emitir la lista actualizada de solicitudes filtradas
        yield filteredRequests;

        // Limpiar la lista de IDs para la próxima iteración
        currentRequestIds.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener solicitudes filtradas: $e');
      }
      yield [];
    }
  }



  Future<Map<String, dynamic>> fetchDistanceAndDuration(
      LatLng origin, LatLng destination, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];
        return {
          'duration': duration,
          'distance': distance,
        };
      } else {
        if (kDebugMode) {
          print('Error en la respuesta de la API: ${data['status']}');
        }
        return {
          'duration': null,
          'distance': null,
        };
      }
    }
    throw Exception('Error fetching distance and duration');
  }

  void acceptTravel() async {
    // Obtener la información del viaje como un TravelInfo
    TravelInfo? travelInfo = await _travelInfoProvider.getById(documentId);
    String? idDriver = travelInfo?.idDriver;
    String? idCurrentDriver = _authProvider.getUser()?.uid;

    // Verificar si el objeto travelInfo no es nulo y si el estado ya ha sido aceptado
    if (travelInfo != null && travelInfo.status == 'accepted') {
      if(idDriver != idCurrentDriver){
        // Mostrar un mensaje de advertencia al conductor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este servicio ya ha sido aceptado por otro conductor.'),
            backgroundColor: Colors.red,
          ),
        );
      }

    } else if (travelInfo != null) {
      // Si el servicio no ha sido aceptado, proceder con la lógica de aceptación
      Map<String, dynamic> data = {
        'idDriver': _authProvider.getUser()!.uid,
        'status': 'accepted',
      };
      // Actualizar el documento en Firestore
      _travelInfoProvider.update(data, documentId);
      _geofireProvider.delete(_authProvider.getUser()!.uid);
      actualizarEstadoIsWorkingTrue();
      guardarUltimoCliente();
      _driverProvider.updateIsActiveAFalse(_authProvider.getUser()!.uid);

      // Redirigir a la página del mapa de viajes
      goToTravelMapPage();
    } else {
      // Si travelInfo es nulo, significa que no se encontró el viaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el servicio solicitado.'),
          backgroundColor: Colors.red,
        ),
      );
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
      '00_ultimo_cliente':documentId};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

}