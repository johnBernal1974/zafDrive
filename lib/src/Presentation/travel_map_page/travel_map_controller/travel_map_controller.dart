
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zafiro_conductores/providers/auth_provider.dart';
import 'package:zafiro_conductores/providers/client_provider.dart';
import 'package:zafiro_conductores/providers/driver_provider.dart';
import 'package:zafiro_conductores/providers/geofire_provider.dart';
import 'package:zafiro_conductores/providers/travel_history_provider.dart';
import 'package:zafiro_conductores/providers/travel_info_provider.dart';
import 'package:zafiro_conductores/src/models/client.dart';
import 'package:zafiro_conductores/src/models/travelHistory.dart';
import 'package:zafiro_conductores/src/models/travel_info.dart';
import 'package:zafiro_conductores/utils/utilsMap.dart';
import 'package:location/location.dart' as location;
import 'package:url_launcher/url_launcher.dart';

import '../../../../Helpers/Dates/DateHelpers.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/prices_provider.dart';
import '../../../colors/colors.dart';
import '../../../models/driver.dart';
import '../../../models/prices.dart';
import '../../commons_widgets/bottom_sheets/bottom_sheet_client_info.dart';
import '../../map_driver_page/View/map_driver_page.dart';

class TravelMapController with WidgetsBindingObserver{
  late BuildContext context;
  late Function refresh;
  bool isMoto = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController = Completer();
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
  late GeofireProvider _geofireProvider;
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late ClientProvider _clientProvider;
  late TravelHistoryProvider _travelHistoryProvider;
  late PricesProvider _pricesProvider;
  bool isConected = true;
  late StreamSubscription<DocumentSnapshot<Object?>> _statusSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _driverInfoSuscription;
  late StreamSubscription<DocumentSnapshot<Object?>> _streamStatusController;
  late TravelInfoProvider _travelInfoProvider;
  late BitmapDescriptor fromMarker;
  late BitmapDescriptor toMarker;
  bool showDriverOnTheWayButton = false; //pickup client
  bool showNotifiedUserButton = false;
  bool showStartTravelButton = false;
  bool showFinishTravelButton = false;
  int _remainingTimeInSeconds = 60; // Iniciar el temporizador en 5 minutos (5 * 60 segundos)
  Timer? _timer; // Variable para almacenar el temporizador
  double mts = 0;
  double kms = 0;
  double mtsSuma = 0;
  String? distanciaTotal;
  double kmsTotal = 0;
  Driver? driver;
  Client? client;
  String? _idTravel;
  double? _distanceBetween;
  String? distancia;
  String? distanciaTotalString;
  String? navegadorSelecionado;
  Set<Polyline> polylines ={};
  List<LatLng> points = List.from([]);
  TravelInfo? travelInfo;
  late bool isVisibleCuadroContador = false;
  late bool isDisponibleBotonCancelar = false;
  late bool isVisibleCajonRecorrido = false;
  String? status = '';
  late AudioPlayer _playerHacancelado;
  late AudioPlayer _playerNotificarUsuario;
  bool _soundUsuarioHaCancelado = false;
  int? comision;
  int? tiempoEspera;
  int? nuevoSaldo;
  int? tarifaMinimaRegular;
  int? tarifaMinimaHotel;
  int? tarifaMinimaTurismo;
  String? rolUsuario;
  String? rol = '';
  Marker? currentMarker;
  //Para verificacion de internet
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false; //**para validar el estado de conexion a internet
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;  // Suscripción para escuchar cambios en conectividad
  GoogleMapController? _googleMapController;


  Future? init (BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    WidgetsBinding.instance.addObserver(this);
    _idTravel = ModalRoute.of(context)?.settings.arguments as String;
    _geofireProvider = GeofireProvider();
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _clientProvider = ClientProvider();
    _travelInfoProvider = TravelInfoProvider();
    _travelHistoryProvider = TravelHistoryProvider();
    _pricesProvider = PricesProvider();
    markerDriver = await createMarkerImageFromAssets('assets/images/marcador_carro_azul80px.png');
    markerMotorcycler = await createMarkerImageFromAssets('assets/images/marcador_motos.png');
    fromMarker = await createMarkerImageFromAssets('assets/images/marker_inicio.png');
    toMarker = await createMarkerImageFromAssets('assets/images/marker_destino.png');
    checkGPS();
    getDriverInfo();
    getClientInfo();
    await checkConnectionAndShowSnackbar();
    obtenerStatus();
    obtenerNavegadorSeleccionado ();
    obtenerDatosPrice();
    _playerNotificarUsuario = AudioPlayer();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
    });
    try {
      if (travelInfo != null) {
        updateButtonVisibility();
      } else {
        if (kDebugMode) {
          print('el travelinfo es nulo');
        }
      }
    } catch (error) {
      // Manejar el error al obtener travelInfo
    }
  }



  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    await _connectionService.checkConnectionAndShowSnackbar(context, () {
      refresh();
    });
  }

  void dispose(){
    _positionStream.cancel();
    _statusSuscription.cancel();
    _driverInfoSuscription.cancel();
    _streamStatusController.cancel();
    _connectivitySubscription?.cancel();
    _googleMapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void saveLocation() async {
    User? user = _authProvider.getUser();
    if (user != null) {
      await _geofireProvider.createWorking(
          user.uid,
          _position.latitude,
          _position.longitude);
    } else {
      if (kDebugMode) {
        print("El usuario es nulo");
      }
    }
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = (await Geolocator.getLastKnownPosition())!;
      _getTravelInfo();
      centerPosition();
      saveLocation();
      refresh();
      // Establecer el marcador inicial
      setInitialMarker();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5),
      ).listen((Position position) {
        // Actualizar la distancia recorrida solo si el viaje ha comenzado
        if (travelInfo != null && travelInfo?.status == 'started') {
          mtsSuma = Geolocator.distanceBetween(_position.latitude, _position.longitude, position.latitude, position.longitude);
          mts += mtsSuma;
          kms = mts / 1000;
          double distanciaEnKms = kms;
          distancia = distanciaEnKms < 1
              ? '${(mts).toStringAsFixed(1)} mts'
              : '${distanciaEnKms.toStringAsFixed(1)} kms';
          actualizarDistanciaRecorrida(mtsSuma);
        }
        // Actualizar la posición actual
        _position = position;
        // Eliminar el marcador anterior
        markers.remove(const MarkerId('driver'));
        // Crear y agregar el nuevo marcador con rotación
        currentMarker = Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(_position.latitude, _position.longitude),
          icon: (rol == 'moto') ? markerMotorcycler : markerDriver,
          infoWindow: const InfoWindow(title: "Tu posición", snippet: ""),
          rotation: _position.heading, // Aplicar rotación
          anchor: const Offset(0.5, 0.5), // Ajustar el ancla para rotación correcta
        );
        markers[const MarkerId('driver')] = currentMarker!;
        animateCameraToPosition(_position.latitude, _position.longitude);
        if (travelInfo?.fromLat != null && travelInfo?.fromLng != null) {
          LatLng from = LatLng(_position.latitude, _position.longitude);
          LatLng to = LatLng(travelInfo!.fromLat, travelInfo!.fromLng);
          isCloseToPickupPosition(from, to);
        }
        saveLocation();
        refresh();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error en la localizacion: $error');
      }
    }
  }

  void setInitialMarker() {
    currentMarker = Marker(
      markerId: const MarkerId('driver'),
      position: LatLng(_position.latitude, _position.longitude),
      icon: (rol == 'moto') ? markerMotorcycler : markerDriver,
      infoWindow: const InfoWindow(title: "Tu posición", snippet: ""),
      anchor: const Offset(0.5, 0.5),
      rotation: _position.heading, // Asegúrate de que la rotación se aplique
    );
    markers[const MarkerId('driver')] = currentMarker!;
    refresh();
  }

  void obtenerRol() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Drivers') // Cambia 'drivers' según tu estructura
        .doc(user?.uid)
        .get();
    rol = userDoc.get('rol');
  }

  Future<void> actualizarDistanciaRecorrida(double distancia) async {
    try {
      TravelInfo? travelInfo = await _travelInfoProvider.getById(_idTravel ?? "");
      if (travelInfo != null) {
        double distanciaAlmacenada = travelInfo.distanciaRecorrida;
        double distanciaTotal = distanciaAlmacenada + mtsSuma;

        double distanciaTotalEnKms = distanciaTotal;
        if (distanciaTotalEnKms < 1) {
          distanciaTotalString = '${(distanciaTotal / 1000).toStringAsFixed(1)} mts'; // Asigna 0 si mts es null
        } else {
          distanciaTotalString = '${ (distanciaTotal /1000).toStringAsFixed(1)} kms';
        }
        await _travelInfoProvider.updateDistanciaRecorrida(_idTravel ?? "", distanciaTotal);
        refresh();
      } else {
        if (kDebugMode) {
          print('No se encontró información de viaje para el ID proporcionado.');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al actualizar la distancia recorrida: $error');
      }
    }
  }

  void checkGPS() async{
    bool islocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(islocationEnabled){
      updateLocation();
    }
    else{
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void obtenerDatosPrice() async {
    try {
      Price price = await _pricesProvider.getAll();
      // Convertir a double explícitamente si es necesario
      comision = price.theComision;
      tiempoEspera = price.theTiempoDeEspera;
      _remainingTimeInSeconds = tiempoEspera!;
      tarifaMinimaRegular = price.theTarifaMinimaRegular;
      tarifaMinimaHotel = price.theTarifaMinimaHotel;
      tarifaMinimaTurismo = price.theTarifaMinimaTurismo;
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo los datos: $e');
      }
    }
  }

  String getFormattedRemainingTime() {
    final minutes = (_remainingTimeInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTimeInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _checkInternetConnectionAndExecute(BuildContext context, Function onSuccess) async {
    bool isConnected = await _connectionService.hasInternetConnection();
    if (!isConnected) {
      Future.microtask(() {
        _showNoConnectionDialog(context);
      });
    } else {
      onSuccess();
    }
  }

// Función para mostrar el AlertDialog de falta de conexión
  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sin Internet', style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold
        ),),
        content: const Text('Por favor, verifica tu conexión.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget pickupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _checkInternetConnectionAndExecute(context, () {
          driverOnTheWay(); // Llama a la función solo si hay conexión
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return primary; // Color de fondo primario
          },
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recoger usuario',
            style: TextStyle(
              color: Colors.white, // Color de texto blanco
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8), // Espacio entre el texto y el ícono
          Icon(
            Icons.touch_app_outlined, // Ícono de doble flecha a la derecha
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget notifyClientButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (_distanceBetween != null && _distanceBetween! <= 200) ? () {
        // Validar conexión a Internet antes de notificar al cliente
        _checkInternetConnectionAndExecute(context, () {
          driverisWaiting();
          startTimer();
        });
      } : () {
        // Mostrar alerta cuando la distancia es mayor a 200 o _distanceBetween es nulo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Alerta"),
              content: const Text("Debes estar más cerca al usuario para notificar tu llegada."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            // Cambiar el color del botón cuando está deshabilitado
            return (_distanceBetween != null && _distanceBetween! <= 200) ? primary : Colors.grey; // Color de fondo si está habilitado o deshabilitado
          },
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Notificar llegada',
            style: TextStyle(
              color: Colors.white, // Color de texto blanco
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8), // Espacio entre el texto y el ícono
          Icon(
            Icons.touch_app_outlined, // Ícono de doble flecha a la derecha
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget startTravelButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primary, // Color existente
            turquesa,   // Color turquesa
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Color de la sombra
            blurRadius: 12.0, // Desenfoque
            offset: const Offset(0, 6), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Validar conexión a Internet antes de iniciar el viaje
          _checkInternetConnectionAndExecute(context, () {
            startTravel(); // Iniciar el viaje
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent), // Hacer el fondo transparente
          elevation: MaterialStateProperty.all(0), // Sin elevación del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Iniciar Viaje',
              style: TextStyle(
                color: Colors.white, // Color de texto blanco
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 8), // Espacio entre el texto y el ícono
            Icon(
              Icons.touch_app_outlined, // Ícono de doble flecha a la derecha
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget finishTravelButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primary, // Color existente
            turquesa,   // Color turquesa
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Color de la sombra
            blurRadius: 12.0, // Desenfoque
            offset: const Offset(0, 6), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Validar conexión a Internet antes de finalizar el viaje
          _checkInternetConnectionAndExecute(context, () {
            finishTravel(); // Finalizar el viaje
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent), // Hacer el fondo transparente
          elevation: MaterialStateProperty.all(0), // Sin elevación del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Finalizar Viaje',
              style: TextStyle(
                color: Colors.white, // Color de texto blanco
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8), // Espacio entre el texto y el ícono
            Icon(
              Icons.double_arrow_rounded, // Ícono de doble flecha a la derecha
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    isVisibleCuadroContador = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTimeInSeconds = _remainingTimeInSeconds - 1;
      refresh();
      if (_remainingTimeInSeconds == 0) {
        timer.cancel();
        isDisponibleBotonCancelar = true;
      }
      isVisibleCajonRecorrido = true;
    });
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  void obtenerStatus() async {
    Stream<DocumentSnapshot> stream = _travelInfoProvider.getByIdStream(_idTravel!);
    _streamStatusController = stream.listen((DocumentSnapshot document) {
      if (document.exists && document.data() != null) {
        travelInfo = TravelInfo.fromJson(document.data() as Map<String, dynamic>);
        status = travelInfo!.status;
        if (status == 'cancelTravelByClient') {
           _positionStream.cancel();
          _geofireProvider.delete(_authProvider.getUser()!.uid);
          _soundElUsuarioHaCancelado('assets/audio/usuario_cancelo_servicio.mp3');
          Navigator.pushReplacementNamed(context, 'map_driver');
          actualizarEstadoIsWorkingFalse();
          Snackbar.showSnackbar(context, key, 'El usuario canceló el servicio');
         }

      } else {
        // El documento no existe
        _positionStream.cancel();
        Navigator.pushReplacementNamed(context, 'map_driver');
        actualizarEstadoIsWorkingFalse();
        _soundElUsuarioHaCancelado('assets/audio/usuario_cancelo_servicio.mp3');
        Snackbar.showSnackbar(context, key, 'El usuario canceló el servicio');
       }
    });
  }

  void _soundElUsuarioHaCancelado(String audioPath) async {
    if (!_soundUsuarioHaCancelado) {
      _playerHacancelado = AudioPlayer();
      try {
        _soundUsuarioHaCancelado = true;
        await _playerHacancelado.setAsset(audioPath);
        await _playerHacancelado.play();
        await _playerNotificarUsuario.stop();


      } catch (e) {
        if (kDebugMode) {
          print('Error al reproducir: $e');
        }
      }
    }
  }

  void _getTravelInfo() async {
    travelInfo = await _travelInfoProvider.getById(_idTravel!);
    String status = travelInfo!.status;
    LatLng from = LatLng(_position.latitude, _position.longitude);
    LatLng to = LatLng(travelInfo!.fromLat, travelInfo!.fromLng);
    // Mostrar los botones según el estado del viaje
    switch (status) {
      case 'accepted':
        showDriverOnTheWayButton = true;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
      case 'driver_on_the_way':
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = true;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
      case 'driver_is_waiting':
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = true;
        showFinishTravelButton = false;
        isVisibleCuadroContador = true;
        startTimer();
        setPolylines(from, to);
        break;
      case 'started':
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = true;
        setPolylines(from, LatLng(travelInfo!.toLat, travelInfo!.toLng));
        break;
      default:
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
    }
    if (status == 'accepted' || status == 'driver_on_the_way' || status == 'driver_is_waiting') {
      addMarker('from', to.latitude, to.longitude, 'Recoger aquí', '', fromMarker);
      setPolylines(from, to);
    } else if (status == 'started') {
      addMarker('to', travelInfo!.toLat, travelInfo!.toLng, 'Destino', '', toMarker);
    }
    refresh();
    getClientInfo();
  }

  void cancelTravelafterAccepted() {
    Map<String, dynamic> data = {
      'status': 'cancelByDriverAfterAccepted',
    };
    _travelInfoProvider.update(data, _idTravel!);
    _positionStream.cancel();
    _geofireProvider.delete(_authProvider.getUser()!.uid);
    actualizarEstadoIsWorkingFalse();
    borrarUltimoCliente();
    actualizarContadorCancelaciones();
    _timer?.cancel();
    // Navegación y cierre del AlertDialog
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MapDriverPage()),
          (route) => false, // Eliminar todas las rutas previas
    ).then((_) {
      Navigator.pop(context); // Cierra el diálogo
    });
  }

  void cancelTravelTimeIsOver() {
    Map<String, dynamic> data = {
      'status': 'cancelTimeIsOver',
    };
    _travelInfoProvider.update(data, _idTravel!);
    _positionStream.cancel();
    _geofireProvider.delete(_authProvider.getUser()!.uid);
    actualizarEstadoIsWorkingFalse();
    borrarUltimoCliente();
    _timer?.cancel();
    // Navegación y cierre del AlertDialog
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MapDriverPage()),
          (route) => false, // Eliminar todas las rutas previas
    ).then((_) {
      Navigator.pop(context); // Cierra el diálogo
    });
  }

  void updateButtonVisibility() {
    switch (travelInfo!.status) {
      case 'accepted':
        showDriverOnTheWayButton = true;
        break;
      case 'driver_has_arrived':
        showNotifiedUserButton = true;
        break;

      case 'driver_is_waiting':
        showStartTravelButton = true;
        break;

      case 'started':
        showFinishTravelButton = true;
        break;
      default:
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
    }
    refresh();
  }

  void driverOnTheWay () async {
    Map<String , dynamic> data = {
      'status': 'driver_on_the_way'
    };
    await _travelInfoProvider.update(data, _idTravel!);
    travelInfo?.status= 'driver_on_the_way';
    showDriverOnTheWayButton = false;
    showNotifiedUserButton = true;
    if(navegadorSelecionado == 'waze'){
      launchWazeToOrigen(travelInfo!.fromLat, travelInfo!.fromLng);
    }
    else{
      launchGoogleMapsToOrigin(travelInfo!.fromLat, travelInfo!.fromLng);
    }
    refresh();
  }

  void driverisWaiting () async {
    if(_distanceBetween! <= 200){
      Map<String , dynamic> data = {
        'status': 'driver_is_waiting'
      };
      await _travelInfoProvider.update(data, _idTravel!);
      travelInfo?.status= 'driver_is_waiting';
      showNotifiedUserButton= false;
      showStartTravelButton= true;
    }
    refresh();
  }

  void startTravel() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "¿Estás seguro de iniciar el viaje?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Separa los botones
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Usuario seleccionó "Sí"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Botón verde
                  ),
                  child: const Text(
                    "Sí",
                    style: TextStyle(
                      color: Colors.white, // Texto en blanco
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Usuario seleccionó "No"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Botón rojo
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white, // Texto en blanco
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    // Si el usuario selecciona "Sí", continuar con el inicio del viaje
    if (confirm == true) {
      Map<String, dynamic> data = {'status': 'started'};
      await _travelInfoProvider.update(data, _idTravel!);
      travelInfo?.status = 'started';
      showStartTravelButton= false;
      showFinishTravelButton= true;
      isVisibleCuadroContador= false;
      cancelTimer();
      actualizarHoraInicio();
      if(navegadorSelecionado == 'waze'){
        launchWazeToDestino(travelInfo!.toLat, travelInfo!.toLng);
      }
      else{
        launchGoogleMapsToDestination(travelInfo!.toLat, travelInfo!.toLng);
      }
      polylines = {};
      points = List.from([]);
      markers.removeWhere((key, marker) => marker.markerId.value == 'from');
      addMarker('to', travelInfo!.toLat, travelInfo!.toLng, 'Destino', '', toMarker);
      LatLng from = LatLng(_position.latitude, _position.longitude);
      LatLng to = LatLng(travelInfo!.toLat, travelInfo!.toLng);
      setPolylines(from, to);
      refresh();
    }
  }

  void actualizarHoraInicio () async {
    Map<String, dynamic> data = {'horaInicioViaje': DateHelpers.getStartDate()};
    await _travelInfoProvider.update(data, _idTravel!);
    refresh();
  }

  void actualizarHoraFinViaje() async {
    Map<String, dynamic> data = {'horaFinalizacionViaje': DateHelpers.getStartDate()};
    // Actualizar la hora de finalización del viaje en la base de datos
    await _travelInfoProvider.update(data, _idTravel!).then((_) {
      refresh();
      // Si la actualización se completa correctamente, guardar el historial de viaje
      saveTravelHistory();
    }).catchError((error) {
      // Manejar el error en caso de que la actualización falle
      if (kDebugMode) {
        print('Error al actualizar la hora de finalización del viaje: $error');
      }
    });
  }

  void actualizarEstadoIsWorkingTrue () async {
    Map<String, dynamic> data = {
      '00_is_working': true};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void finishTravel() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '¿Estás seguro de terminar el viaje?\n',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Separa los botones
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Usuario seleccionó "Sí"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Botón verde
                  ),
                  child: const Text(
                    "Sí",
                    style: TextStyle(
                      color: Colors.white, // Texto en blanco
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Usuario seleccionó "No"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Botón rojo
                  ),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Colors.white, // Texto en blanco
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      // Obtener la ubicación actual del usuario
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // Obtener la ubicación de destino del viaje (suponiendo que tienes estos datos almacenados)
      double? destinationLatitude = travelInfo?.toLat;
      double? destinationLongitude = travelInfo?.toLng;
      if (destinationLatitude != null && destinationLongitude != null) {
        // Calcular la distancia al destino
        double distanceToDestination = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          destinationLatitude,
          destinationLongitude,
        );
        // Obtener la tarifa inicial del viaje
        double? tarifaInicial = travelInfo?.tarifa;
        if (tarifaInicial != null) {
          // Verificar la distancia y calcular la tarifa
          double tarifaFinal;
          if (distanceToDestination < 1000) { // Menos de 1 km al destino
            tarifaFinal = tarifaInicial;
          } else {
            // Más de 1 km al destino, calcular la tarifa proporcional
            double? distanciaRecorrida = travelInfo?.distanciaRecorrida;
            double? distanciaTotal = travelInfo?.distancia;
            if (distanciaRecorrida != null && distanciaTotal != null) {
              tarifaFinal = (distanciaRecorrida * tarifaInicial) / distanciaTotal;
            } else {
              // Manejar el caso donde distanciaRecorrida es null
              tarifaFinal = tarifaInicial; // Asignar tarifa inicial si no se tiene la distancia recorrida
            }
          }
          // Redondear la tarifa final a la centena mayor
          tarifaFinal = (tarifaFinal / 100).ceil() * 100;
          // Verificar si la tarifa final es menor que la tarifa mínima según el rol del usuario
          int? tarifaMinima;
          if (rolUsuario == 'basico') {
            tarifaMinima = tarifaMinimaRegular;
          } else if (rolUsuario == 'hotel') {
            tarifaMinima = tarifaMinimaHotel;
          } else if (rolUsuario == 'turismo') {
            tarifaMinima = tarifaMinimaTurismo;
          }
          if (tarifaMinima != null && tarifaFinal < tarifaMinima) {
            tarifaFinal = tarifaMinima.toDouble();
          }
          // Actualizar la tarifa en la base de datos
          await _travelInfoProvider.updateTarifa(_idTravel!, tarifaFinal);
          // Actualizar el nuevo saldo con la tarifa final calculada y redondeada
          await actualizarNuevoSaldo(tarifaFinal);
          // Continuar con el resto del proceso
          actualizarHoraFinViaje();
          actualizarContadorDeViajes();
          travelInfo = await _travelInfoProvider.getById(_idTravel!);
          actualizarEstadoIsWorkingFalse();
          borrarUltimoCliente();
          _positionStream.cancel();
          _geofireProvider.delete(_authProvider.getUser()!.uid);
          // saveTravelHistory();
        }
      }
    }
  }

  Future<void> actualizarNuevoSaldo(double tarifaFinal) async {
    double? comisionDouble = comision?.toDouble();
    double valorComision = (tarifaFinal * comisionDouble!) / 100;
    int valorComisionInt = valorComision.toInt();
    int? saldoActual = driver?.the32SaldoRecarga;
    nuevoSaldo = saldoActual! - valorComisionInt;
    Map<String, dynamic> data = {
      '32_Saldo_Recarga': nuevoSaldo,
      '321_Saldo_Anterior_Info': nuevoSaldo
    };
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void launchWazeToOrigen(double latitude, double longitude) async {
    // Reemplaza 'lat', 'lon' con las coordenadas de destino
    String url = "https://waze.com/ul?ll=$latitude,$longitude&navigate=yes";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir waze.';
    }
  }

  void launchWazeToDestino(double latitude, double longitude) async {
    String url = "https://waze.com/ul?ll=$latitude,$longitude&navigate=yes";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir waze.';
    }
  }

  void launchGoogleMapsToOrigin(double latitude, double longitude) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir Google Maps.';
    }
  }

  void launchGoogleMapsToDestination(double latitude, double longitude) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir Google Maps.';
    }
  }

  void obtenerNavegadorSeleccionado () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    navegadorSelecionado = prefs.getString('navegador');
  }

  void botonNavegacionWaze (){
    switch (travelInfo!.status) {
      case 'accepted':
        driverOnTheWay ();
        break;
      case 'driver_on_the_way':
        launchWazeToOrigen(travelInfo!.fromLat, travelInfo!.fromLng);
        break;
      case 'driver_is_waiting':
        startTravel();
        break;
      case 'started':
        launchWazeToDestino(travelInfo!.toLat, travelInfo!.toLng);
        break;
      default:
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
    }
    refresh();
  }

  void botonNavegacionGoogleMaps (){
    switch (travelInfo!.status) {
      case 'accepted':
        driverOnTheWay ();
        break;
      case 'driver_on_the_way':
        launchGoogleMapsToOrigin(travelInfo!.fromLat, travelInfo!.fromLng);
        break;
      case 'driver_is_waiting':
        startTravel();
        break;
      case 'started':
        launchGoogleMapsToDestination(travelInfo!.toLat, travelInfo!.toLng);
        break;
      default:
        showDriverOnTheWayButton = false;
        showNotifiedUserButton = false;
        showStartTravelButton = false;
        showFinishTravelButton = false;
        break;
    }
    refresh();
  }

  void saveTravelHistory () async {
    String inicioViaje = travelInfo?.horaInicioViaje ?? '';
    String finalViaje = travelInfo?.horaFinalizacionViaje ?? '';
    TravelHistory travelHistory = TravelHistory(
        id: '',
        idClient: _idTravel!,
        idDriver: _authProvider.getUser()!.uid,
        from: travelInfo?.from ?? '',
        to: travelInfo?.to ?? '',
        nameDriver: "",
        apellidosDriver: "",
        placa: "",
        solicitudViaje: travelInfo?.horaSolicitudViaje ?? '',
        inicioViaje: inicioViaje,
        finalViaje: finalViaje,
        tarifa: travelInfo?.tarifa ?? 0,
        tarifaDescuento: travelInfo?.tarifaDescuento ?? 0,
        tarifaInicial: travelInfo?.tarifaInicial ?? 0,
        calificacionAlConductor: 0,
        calificacionAlCliente: 0,
        rol: driver!.rol,
        apuntes:travelInfo?.apuntes ?? '',
    );
    String id = await _travelHistoryProvider.create(travelHistory);
    Map<String , dynamic> data = {
      'status': 'finished',
      'idTravelHistory': id,
    };
    await _travelInfoProvider.update(data, _idTravel!);
    travelInfo?.status= 'finished';
    Navigator.pushNamedAndRemoveUntil(context, 'travel_calification_page', (route) => false, arguments: id);
  }

  void isCloseToPickupPosition(LatLng from, LatLng to) {
    _distanceBetween = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude);
  }

  void getDriverInfo(){
    Stream<DocumentSnapshot> driverStream = _driverProvider.getByIdStream(_authProvider.getUser()!.uid);
    _driverInfoSuscription = driverStream.listen((DocumentSnapshot document) {
      driver = Driver?.fromJson(document.data() as Map<String, dynamic>);
      obtenerRol();
      refresh();
    });
  }

  void getClientInfo() async {
    client = await _clientProvider.getById(_idTravel!);
    rolUsuario = client?.the20Rol;
  }

  Future<void> setPolylines(LatLng from, LatLng to) async {
    points = List.from([]);
    PointLatLng pointFromLatlng = PointLatLng(from.latitude, from.longitude);
    PointLatLng pointToLatlng = PointLatLng(to.latitude, to.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      _yourGoogleAPIKey,
      pointFromLatlng,
      pointToLatlng,
    );
    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }
    Polyline polyline = Polyline(
      polylineId: const PolylineId('poly'),
      color: Colors.black87,
      points: points,
      width: 4,
    );
    polylines.add(polyline);
    refresh();
  }

  void onMapCreated(GoogleMapController controller){
    _googleMapController = controller;
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
    controller.setMapStyle(utilsMap.mapStyle);
    _mapController.complete(controller);
  }

  Future<void> animateCameraToPosition(double latitude, double longitude) async {
    if (_googleMapController == null) return;
    _googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 15.3,
      ),
    ));
  }

  Future? animateCameraToPositionCenterPosition(double latitude, double longitude)  async {
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(latitude,longitude),
            zoom: 14
        )
    )
    );
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
    );
    markers[id] = marker;
  }

  void centerPosition(){
    animateCameraToPositionCenterPosition (_position.latitude, _position.longitude);

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

  void openBottomSheetClientInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite controlar la altura
      backgroundColor: Colors.transparent, // Para que el fondo detrás sea visible
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.45, // Ocupa el 50% de la pantalla
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Fondo del BottomSheet
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomSheetClientInfo(
            imageUrl: client?.image ?? '',
            name: client?.the01Nombres ?? '',
            apellido: client?.the02Apellidos ?? '',
            calificacion: client?.the18Calificacion.toString() ?? '',
            numeroNviajes: client?.the19Viajes.toString() ?? '',
            celular: client?.the07Celular ?? '',
            clientId: client?.id ?? '',
          ),
        ),
      ),
    );
  }

  void actualizarEstadoIsWorkingFalse () async {
    Map<String, dynamic> data = {
      '00_is_working': false};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void actualizarContadorDeViajes () async {
    int? numeroDeViajes = driver?.the30NumeroViajes;
    int nuevoContador = numeroDeViajes! + 1;
    Map<String, dynamic> data = {
      '30_Numero_viajes': nuevoContador};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void actualizarContadorCancelaciones () async {
    int? numeroCancelaciones = driver?.the40NumeroCancelaciones;
    int nuevoContadorCancelaciones = numeroCancelaciones! + 1;
    Map<String, dynamic> data = {
      '40_Numero_Cancelaciones': nuevoContadorCancelaciones};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

  void borrarUltimoCliente () async {
    Map<String, dynamic> data = {
      '00_ultimo_cliente':''};
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
    refresh();
  }

}
