import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import '../../../../Helpers/Validators/FormValidators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../../antes_inicar_page/View/antes_inicar_page.dart';
import '../../login_page/View/login_page.dart';
import '../map_driver_controller/map_driver_controller.dart';

class MapDriverPage extends StatefulWidget {
  const MapDriverPage({super.key});

  @override
  State<MapDriverPage> createState() => _MapDriverPageState();
}

class _MapDriverPageState extends State<MapDriverPage>  with WidgetsBindingObserver{

  final DriverMapController _controller = DriverMapController();
  late MyAuthProvider _authProvider;
  String? formattedSaldo;
  Timer? _batteryOptimizationCheckTimer;
  Timer? _locationDeniedPermanentlyTimer;
  Timer? _locationDeniedTimer;
  StreamSubscription<List<Map<String, dynamic>>>? _requestsSubscription;
  double saldo= 0;
  final ConnectionService connectionService = ConnectionService();


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      checkAndRequestBatteryOptimization();
    });
    WidgetsBinding.instance.addObserver(this);
    _authProvider = MyAuthProvider();
    requestLocationPermission();
    _fetchData();
    _controller.obtenerRol();
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _batteryOptimizationCheckTimer?.cancel();
    _locationDeniedPermanentlyTimer?.cancel();
    _locationDeniedTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    formattedSaldo =
        FormatUtils.formatCurrency(_controller.driver?.the32SaldoRecarga ?? 0);
    return Scaffold(
      backgroundColor: grisMapa,
      key: _controller.key,
      drawer: _drawer(),
      body: Column(
        children: [
          // Mapa en el Stack (40% de la pantalla)
          Stack(
            children: [
              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.4, // 40% de la pantalla
                child: _googleMapsWidget(),
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonDrawer(),
                    _buttonDesconectar(context, connectionService),
                    _buttonCenterPosition(),
                  ],
                ),
              ),
            ],
          ),
          _saldoRecarga(),
          // Expande el contenido para ser desplazable (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Drivers')
                            .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error al cargar saldo');
                          } else if (!snapshot.hasData || !snapshot.data!
                              .exists) {
                            return const Text('Saldo no disponible');
                          } else {
                            saldo = snapshot.data!['32_Saldo_Recarga']
                                ?.toDouble() ?? 0.0;
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                  // Lista de solicitudes de servicio
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _controller.fetchFilteredRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(
                              top: 60, left: 15, right: 15),
                          child: const Column(
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.red,
                                  size: 60.0),
                              SizedBox(height: 20),
                              Text(
                                'No hay solicitudes en este momento.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Recuerda mantenerte conectado para recibir solicitudes.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      final requests = snapshot.data ?? [];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: requests.map((request) {
                            return GestureDetector(
                              onTap: () {
                                // Validación de saldo antes de aceptar el servicio
                                if (saldo <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Saldo insuficiente para aceptar el servicio'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  _onCardTap(request['id'] as String,
                                      connectionService);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(offset: Offset(0.0, 5.0),
                                        blurRadius: 10,
                                        color: gris)
                                  ],
                                  color: blanco,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: negro, width: 2.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          '\$ ${NumberFormat('#,##0', 'es_ES')
                                              .format((request['tarifa'] as num)
                                              .round())}',
                                          style: const TextStyle(fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: negro),
                                        ),
                                       Text(
                                            '${request['tipoServicio']}',
                                            style: const TextStyle(fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.red),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Divider(
                                        height: 1, color: Colors.grey.shade200),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Column(
                                          children: [
                                            Image.asset(
                                                'assets/images/marker_inicio.png',
                                                width: 12, height: 12),
                                            Container(height: 10,
                                                width: 2,
                                                color: negro),
                                            Image.asset(
                                                'assets/images/marker_destino.png',
                                                width: 12, height: 12),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text('${request['from']}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                              const SizedBox(height: 5),
                                              Divider(height: 1,
                                                  color: Colors.grey.shade400),
                                              Text('${request['to']}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Divider(
                                        height: 1, color: Colors.grey.shade400),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 12,
                                                color: Colors.black),
                                            const SizedBox(width: 5),
                                            const Text('Usuario a:',
                                                style: TextStyle(fontSize: 10,
                                                    fontWeight: FontWeight
                                                        .w600)),
                                            const SizedBox(width: 5),
                                            Text('${request['distancia']}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 12,
                                                color: Colors.black),
                                            const SizedBox(width: 5),
                                            const Text('Tiempo:',
                                                style: TextStyle(fontSize: 10,
                                                    fontWeight: FontWeight
                                                        .w600)),
                                            const SizedBox(width: 5),
                                            Text('${request['tiempoViaje']}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                        height: 1, color: Colors.grey.shade400),
                                    const SizedBox(height: 5),
                                    const Text('Apuntes del Cliente',
                                        style: TextStyle(fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.red)),
                                    Text(
                                      request['apuntes']?.isNotEmpty == true
                                          ? request['apuntes']
                                          : 'Sin Apuntes del cliente.',
                                      style: const TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCardTap(String documentId, ConnectionService connectionService) async {
    // Verificar la conexión a Internet
    bool hasConnection = await connectionService.hasInternetConnection();

    // Una vez verificada la conexión, decide cuál diálogo mostrar
    if (hasConnection) {
      _mostrarDialogoAceptarServicio(documentId);
    } else {
      alertSinInternet();
    }
  }

// Método separado para mostrar el diálogo de aceptar servicio
  void _mostrarDialogoAceptarServicio(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Aceptar Servicio',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: const Text('¿Quieres aceptar este servicio?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    _controller.acceptTravel();   // Llama a la función de aceptar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color del botón
                  ),
                  child: const Text('Aceptar', style: TextStyle(color: blanco)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color del botón
                  ),
                  child: const Text('No', style: TextStyle(color: blanco)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Future<void> _fetchData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _requestsSubscription?.cancel();
      // Suscribimos al Stream para recibir actualizaciones en tiempo real
      _requestsSubscription = _controller.fetchFilteredRequestsStream().listen((requests) {
        // if(mounted){
        //   setState(() {
        //     _requestCount = requests.length;
        //   });
        // }
      });
    }
  }

  Widget _googleMapsWidget() {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.5,  // Ocupa el 50% de la pantalla
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _controller.initialPosition,
        onMapCreated: _controller.onMapCreated,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: false,
        markers: Set<Marker>.of(_controller.markers.values),
      ),
    );
  }

  void refresh() {
    setState(() {
    });
  }

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: _controller.centerPosition,
      child: Container(
        alignment: Alignment.bottomRight,
        margin: const EdgeInsets.only(right: 10),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 2,
          child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0.0, 15.0),
                    blurRadius: 25,
                    color: gris,
                  )
                ],
                color: blanco,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.location_searching, color: negro, size:20,)),
        ),
      ),
    );
  }

  bool _isLoading = false; // Añadir esta variable para controlar el estado de carga

  Widget _buttonDesconectar(BuildContext context, ConnectionService connectionService) {
    return GestureDetector(
      onTap: _isLoading // Desactivar el tap si está cargando
          ? null
          : () async {
        setState(() {
          _isLoading = true; // Iniciar el estado de carga
        });
        // Verificar la conexión a Internet antes de desconectar
        bool hasConnection = await connectionService.hasInternetConnection();
        if (hasConnection) {
          // Si hay conexión, procede a desconectar
          _controller.disconnect();
          // Usa un Navigator en un Future para evitar el contexto asíncrono
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AntesIniciarPage()),
            );
          });
        } else {
          // Si no hay conexión, muestra un AlertDialog
          alertSinInternet();
        }
        setState(() {
          _isLoading = false; // Terminar el estado de carga
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: 30,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              offset: Offset(0.0, 15.0),
              blurRadius: 25,
              color: gris,
            ),
          ],
          color: blanco,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 30,
              width: 150,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  topLeft: Radius.circular(100),
                  bottomRight: Radius.circular(200),
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                child: _isLoading // Mostrar indicador de carga o texto
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(blanco),
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Desconectarse',
                  style: TextStyle(
                    color: blanco,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: _isLoading // Mostrar el icono solo si no está cargando
                  ? Container()
                  : const Icon(
                Icons.cancel_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future alertSinInternet (){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Internet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
          content: const Text('Por favor, verifica tu conexión e inténtalo nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _drawer() {
    return Drawer(
      backgroundColor: blanco,
      semanticLabel: 'Drawer',
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        _controller.goToProfile();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primary, // Color del borde
                            width: 1, // Ancho del borde
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundColor: blanco,
                          backgroundImage: _controller.driver?.image != null
                              ? CachedNetworkImageProvider(_controller.driver!.image)
                              : null,
                          radius: 45,
                        ),
                      )),
                  Text(
                    _controller.driver?.the01Nombres ?? '',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: blanco),
                    maxLines: 1,
                  ),
                  Text(
                    _controller.driver?.the02Apellidos ?? '',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: blanco),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem('Historial de viajes', Icons.history, _controller.goToHistorialViajes),
          _buildDrawerItem('Historial de recargas', Icons.account_balance_wallet, _controller.goToHistorialRecargas),
          _buildDrawerItem('Recargar', Icons.credit_card, _controller.goToRecargar),
          _buildDrawerItem('Elegir navegador', Icons.map, _controller.goToElegirNavegador),
          _buildDrawerItem('Políticas de privacidad', Icons.privacy_tip, _controller.goToPoliticasDePrivacidad),
          _buildDrawerItem('Permisos de ubicación', Icons.location_on, _controller.goToPermisosDeUbicacion),
          _buildDrawerItem('Contáctanos', Icons.phone, _controller.goToContactanos),
          _buildDrawerItem('Compartir aplicación', Icons.share, _controller.goToCompartirAplicacion),
          const Divider(color: grisMedio),
          _buildDrawerItem('Eliminar cuenta', Icons.delete, _controller.goToEliminarCuenta),
          ListTile(
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: negroLetras,
                  fontSize: 14
              ),
            ),
            leading: const Icon(
              Icons.logout, // Icono para cerrar sesión
              size: 20, // Tamaño del icono
              color: negroLetras, // Color del icono (puedes ajustar si lo deseas)
            ),
            onTap: () async {
              // Guarda una referencia local del contexto
              final currentContext = context;
              // Verificar la conexión a Internet
              bool hasConnection = await connectionService.hasInternetConnection();
              if (hasConnection) {
                if (currentContext.mounted) {
                  Navigator.pop(currentContext);
                  _mostrarAlertDialog(currentContext);
                }
              } else {
                if (currentContext.mounted) {
                  alertSinInternet();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, dynamic iconOrImage, Function onTap, {double iconSize = 24.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5), // Ajusta el valor del padding
      child: ListTile(
        leading: iconOrImage is String
            ? Image.asset(iconOrImage)
            : Icon(iconOrImage, size: iconSize),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        onTap: () => onTap(),
      ),
    );
  }

  Widget _saldoRecarga() {
    return Container(
      width: double.infinity,
      color: grisMapa,
      padding: const EdgeInsets.symmetric(vertical: 15), // Padding vertical para darle espacio
      child: Center(
        child: Container(
          height: 35,
          width: 200, // Este ancho es específico para el contenedor del saldo
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                offset: Offset(0.0, 7.0),
                blurRadius: 18,
                color: gris,
              )
            ],
            color: blanco,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 35,
                width: 80,
                decoration: const BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    topLeft: Radius.circular(22),
                    bottomRight: Radius.circular(200),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Saldo',
                    style: TextStyle(
                      color: blanco,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: negro,
                  ),
                  child: Text(formattedSaldo ?? ''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonDrawer() {
    return GestureDetector(
      onTap: _controller.opendrawer, // Acción al pulsar el botón
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 10), // Margen izquierdo para separar del borde
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          surfaceTintColor: blanco,
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0.0, 15.0),
                  blurRadius: 25,
                  color: gris,
                ),
              ],
              color: blanco, // Color de fondo del ícono
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(
              Icons.menu,
              color: negro,
              size: 20, // Tamaño del ícono
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cierre de sesión',
            textAlign: TextAlign.center,
            style: TextStyle(color: negro, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro que quieres cerrar la sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async{
                      // Guarda una referencia local del contexto
                      final currentContext = context;
                      // Verificar la conexión a Internet
                      bool hasConnection = await connectionService.hasInternetConnection();
                      if (hasConnection) {
                        if (currentContext.mounted) {
                          _authProvider.signOut();
                          _controller.disconnect();
                          Navigator.pushReplacement(context,
                              PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginPage()));
                        }
                      } else {
                        if (currentContext.mounted) {
                          alertSinInternet();
                        }
                      }
                    },
                    child: const Text(
                      'Sí',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: negro),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: negro),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permiso otorgado, puedes proceder con la lógica que requiere el permiso
    } else if (status.isDenied) {
      // Permiso denegado por el usuario, muestra un mensaje o realiza alguna acción
      showLocationPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      // Permiso permanentemente denegado, muestra un mensaje indicando cómo el usuario puede habilitar el permiso en la configuración de la aplicación
      showPermanentlyDeniedDialog();
    }
  }

  void showLocationPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Crear un temporizador para verificar el estado del permiso
        _locationDeniedTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          var status = await Permission.location.status; // Verificar el estado del permiso
          if (status.isGranted) {
            // Si el permiso es concedido, cerrar el diálogo
            if(context.mounted){
              Navigator.of(context).pop();
            }
            timer.cancel(); // Cancelar el temporizador
          }
        });
        return AlertDialog(
          title: Column(
            children: [
              Icon(
                Icons.location_on, // Ícono de ubicación
                color: Theme.of(context).primaryColor, // Color del ícono basado en el color primario de la app
                size: 40, // Tamaño del ícono
              ),
              const SizedBox(height: 10), // Espacio entre el ícono y el título
              const Text("Permiso de ubicación denegado", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                textAlign: TextAlign.center,)
            ],
          ),
          content: const Text(
              "Para que la aplicación funcione correctamente, necesitas habilitar el permiso de ubicación."),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Configuración"),
              onPressed: () {
                openAppSettings(); // Abrir la configuración de la app
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cancelar el temporizador si el diálogo se cierra manualmente
      _locationDeniedTimer?.cancel();
    });
  }

  // Mostrar un diálogo cuando el usuario deniega permanentemente el permiso
  void showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Crear un temporizador para verificar el estado del permiso
        _locationDeniedPermanentlyTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          var status = await Permission.location.status; // Verificar el estado del permiso
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
                Icons.location_on, // Ícono de ubicación
                color: Theme.of(context).primaryColor, // Color del ícono basado en el color primario de la app
                size: 40, // Tamaño del ícono
              ),
              const SizedBox(height: 10), // Espacio entre el ícono y el título
              const Text("Has denegado el Permiso de ubicación.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                textAlign: TextAlign.center,),
            ],
          ),
          content: const Text(
            "Para que tu aplicación funcione de manera correcta y se habilite la función de seguimiento en tiempo real, necesitas habilitar el permiso de ubicación \"TODO EL TIEMPO\".",
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Configuración"),
              onPressed: () {
                openAppSettings(); // Abrir la configuración de la app
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cancelar el temporizador si el diálogo se cierra manualmente
      _locationDeniedPermanentlyTimer?.cancel();
    });
  }

  void checkAndRequestBatteryOptimization() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final packageInfo = await PackageInfo.fromPlatform();
    if (androidInfo.version.sdkInt >= 23) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isGranted) {
        if (kDebugMode) {
          print("La optimización de batería ya está deshabilitada.");
        }
      } else if (status.isDenied) {
        showBatteryOptimizationDialog(packageInfo.packageName);
      }
    }
  }

  void showBatteryOptimizationDialog(String packageName) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        // Comenzar a revisar el estado de optimización de batería cada 2 segundos
        _batteryOptimizationCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          final status = await Permission.ignoreBatteryOptimizations.status;
          if (status.isGranted) {
            // Cerrar el diálogo si la optimización de batería está deshabilitada
            if(context.mounted){
              Navigator.of(context).pop();
            }
            timer.cancel();
          }
        });
        return AlertDialog(
          title: const Text("Optimización de batería"),
          content: const Text(
              "Para que Tay-rona funcione correctamente en segundo plano, desactiva la optimización de batería. Debe estar sin restricciones "),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Configuración"),
              onPressed: () {
                openBatteryOptimizationSettings(packageName);
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Cancelar el temporizador si el diálogo se cierra manualmente
      _batteryOptimizationCheckTimer?.cancel();
    });
  }

  void openBatteryOptimizationSettings(String packageName) {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:$packageName',
    );
    intent.launch();
  }
}
