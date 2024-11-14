
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zafiro_conductores/src/Presentation/travel_map_page/travel_map_controller/travel_map_controller.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';


class TravelMapPage extends StatefulWidget {
  const TravelMapPage({super.key, required arguments});

  @override
  State<TravelMapPage> createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {

  late final TravelMapController _controller = TravelMapController();
  double? tarifaDouble = 0;
  String? formattedTarifa;
  late bool isVisibleCuadroContador = false;
  late bool isVisibleBotonCancelar = false;
  late bool isVisibleCajonRecorrido = false;
  final ConnectionService connectionService = ConnectionService();
  bool _isLoadingNavegar = false;
  bool _isLoadingCancel = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
    _formatearTarifa();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: grisMapa,
      key: _controller.key,
      body: Stack(
        children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buttonCenterPosition(),
                    _clickUsuarioServicio(),
                  ],
                ),
                Expanded(child: Container()),
                _cajonInfoViaje(),
              ],
            ),
          ),        ],
      ),
    );
  }

  void _formatearTarifa(){
    final tarifa = _controller.travelInfo?.tarifa;
    if (tarifa != null) {
      tarifaDouble = tarifa;
      formattedTarifa = formatTarifa(tarifa);
    } else {
      if (kDebugMode) {
        print('La tarifa es nula');
      }
    }
  }

  String formatTarifa(double tarifa) {
    // Redondear la tarifa a un número entero
    int roundedTarifa = tarifa.round();
    // Formatear la tarifa con el separador de miles y sin decimales
    String formattedTarifa = NumberFormat.currency(locale: 'es_ES', symbol: '', decimalDigits: 0).format(roundedTarifa);
    // Agregar el símbolo de pesos al principio
    formattedTarifa = '\$ $formattedTarifa';
    return formattedTarifa;
  }

  Widget _googleMapsWidget() {
    double mapHeight;
    if (_controller.travelInfo?.status == 'driver_is_waiting') {
      mapHeight = MediaQuery.of(context).size.height * 0.50;
    } else if (_controller.travelInfo?.status == 'started') {
      mapHeight = MediaQuery.of(context).size.height * 0.70; // 70% de la altura para el estado 'started'
    } else {
      mapHeight = MediaQuery.of(context).size.height * 0.70;
    }
    return SizedBox(
      height: mapHeight,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _controller.initialPosition,
        onMapCreated: _controller.onMapCreated,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: false,
        markers: Set<Marker>.of(_controller.markers.values),
        polylines: _controller.polylines,
      ),
    );
  }

  Widget _cajonInfoViaje() {
    double containerHeight;
    if (_controller.travelInfo?.status == 'driver_is_waiting') {
      containerHeight = MediaQuery.of(context).size.height * 0.50;
    } else if (_controller.travelInfo?.status == 'started') {
      containerHeight = MediaQuery.of(context).size.height * 0.30; // Ajusta este valor según lo necesario
    }
    else {
      containerHeight = MediaQuery.of(context).size.height * 0.30;
    }
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 120), // Aumenta el margen superior
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: blancoCards,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary,
                        turquesa,
                        turquesa,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        const Text(
                          'VALOR DEL VIAJE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: blanco,
                          ),
                        ),
                        const Spacer(),
                        _infoTarifa()
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Row(
                  children: [
                  // Cambiar el ícono por imágenes
                  _controller.travelInfo?.status == 'accepted' ||
                  _controller.travelInfo?.status == 'driver_on_the_way'
                  ? Image.asset(
                    'assets/images/marker_inicio.png',
                    height: 20, // Ajusta el tamaño de la imagen
                    width: 20,
                  )
                      : Image.asset(
                  'assets/images/marker_destino.png',
                  height: 16, // Ajusta el tamaño de la imagen
                  width: 16,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _controller.travelInfo?.status == 'accepted' ||
                        _controller.travelInfo?.status == 'driver_on_the_way'
                        ? 'Origen'
                        : 'Destino',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: _controller.travelInfo?.status == 'accepted' ||
                          _controller.travelInfo?.status == 'driver_on_the_way'
                          ? negro
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _controller.travelInfo?.status == 'accepted' ||
                            _controller.travelInfo?.status == 'driver_on_the_way'
                            ? _controller.travelInfo?.from ?? ''
                            : _controller.travelInfo?.to ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: negro,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 10),
              Visibility(
                visible: _controller.isVisibleCuadroContador,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Tiempo de espera',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _controller.getFormattedRemainingTime(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _cancelarTimeIsOverButon()
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 8.0, // Espacio horizontal entre los botones
                  runSpacing: 4.0, // Espacio vertical entre las líneas de botones
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    if (_controller.showDriverOnTheWayButton)
                      _controller.pickupButton(context),
                    if (_controller.showNotifiedUserButton)
                      _controller.notifyClientButton(context),
                    if (_controller.showStartTravelButton)
                      _controller.startTravelButton(context),
                    if (_controller.showFinishTravelButton)
                      _controller.finishTravelButton(context),
                    Visibility(
                      visible: _controller.travelInfo?.status == 'accepted' ||
                          _controller.travelInfo?.status == 'driver_on_the_way',
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingCancel
                            ? null // Desactiva el botón si está cargando
                            : () async {
                          setState(() {
                            _isLoadingCancel = true; // Iniciar el estado de carga
                          });

                          bool hasConnection = await connectionService.hasInternetConnection();

                          setState(() {
                            _isLoadingCancel = false; // Terminar el estado de carga
                          });

                          if (hasConnection) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _mostrarDialogoCancelar();
                            });

                          } else {
                            // Si no hay conexión, muestra un AlertDialog indicando la falta de conexión
                            alertSinInternet();
                          }
                        },
                        icon: _isLoadingCancel
                            ? Container() // No mostrar icono si está cargando
                            : const Icon(Icons.cancel, color: Colors.white, size: 16),
                        label: _isLoadingCancel
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade400),
                        ),
                      ),
                    )
                   ],
                  ),
                ),
               ],
              ),
             ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          right: 10,
          child: _botonNavegar(context, connectionService),
        ),
      ],
    );
  }

  void _mostrarDialogoCancelar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '¿Está seguro de cancelar el viaje?\n',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '\n',
                style: TextStyle(fontSize: 12),
              ),
              TextSpan(
                text: 'Recuerda que el exceso de cancelaciones de viajes aceptados pueden causar el bloqueo temporal de tu cuenta.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.cancelTravelafterAccepted();
            },
            child: const Text('SI'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {
        _formatearTarifa();
      });
    }
  }

  Widget _cancelarTimeIsOverButon() {
    return ElevatedButton.icon(
      onPressed: _controller.isDisponibleBotonCancelar
          ? () async {
        // Verificación de conexión
        bool hasConnection = await connectionService.hasInternetConnection();
        if (hasConnection) {
          // Asegurarse de que el diálogo se muestre en el siguiente frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mostrarDialogoCancelarTiempoCumplido();
          });
        } else {
          alertSinInternet();
        }
      }
          : null, // Deshabilita el botón cuando no está disponible
      icon: const Icon(
        Icons.cancel,
        color: Colors.white, // Color del ícono
        size: 16, // Tamaño del ícono
      ),
      label: const Text(
        'Cancelar',
        style: TextStyle(
          color: Colors.white, // Color de texto blanco
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return _controller.isDisponibleBotonCancelar
                ? Colors.red.shade400
                : Colors.grey; // Color del botón según su disponibilidad
          },
        ),
      ),
    );
  }

// Método para mostrar el diálogo de confirmación de cancelación
  void _mostrarDialogoCancelarTiempoCumplido() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Ya puedes cancelar el viaje por tiempo de espera cumplido',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Quieres cancelarlo ahora?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el AlertDialog sin hacer nada
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Botón rojo para "NO"
                ),
                child: const Text(
                  'NO',
                  style: TextStyle(
                    color: Colors.white, // Texto en blanco
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Acción para cancelar el viaje
                  _controller.cancelTravelTimeIsOver();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Botón verde para "SI"
                ),
                child: const Text(
                  'SI',
                  style: TextStyle(
                    color: Colors.white, // Texto en blanco
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clickUsuarioServicio() {
    return Visibility(
      visible: _controller.travelInfo != null && ['accepted', 'driver_on_the_way', 'driver_is_waiting', 'driver_has_arrived', 'started'].contains(_controller.travelInfo!.status),
      child: GestureDetector(
        onTap: () {
          if (_controller.travelInfo != null && ['accepted', 'driver_on_the_way', 'driver_is_waiting', 'driver_has_arrived'].contains(_controller.travelInfo!.status)) {
            _controller.openBottomSheetClientInfo();
          }
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: IntrinsicWidth(
            child: Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    turquesa, // Color turquesa
                    turquesa, // Color turquesa
                    primary, // Color existente
                    primary, // Color existente
                  ],
                ), // Color del Container
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(48),
                  bottomLeft: Radius.circular(48),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    offset: const Offset(1, 1),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: blancoCards,
                    backgroundImage: _controller.client?.image != null
                        ? NetworkImage(_controller.client!.image)
                        : null,
                  ),
                  const SizedBox(width: 8), // Espacio entre el CircleAvatar y el Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuario',
                        style: TextStyle(
                          fontSize: 10,
                          color: blanco,
                        ),
                      ),
                      Text(
                        _controller.client?.the01Nombres ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: blanco,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTarifa() {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child:
        Text(
          formattedTarifa ?? '',
          style: const TextStyle(
            fontSize: 20,
            color: blanco,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _botonNavegar(BuildContext context, ConnectionService connectionService) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // Hace el contenedor redondo
        color: blanco,
      ),
      child: SizedBox(
        width: 30,
        height: 30,
        child: _isLoadingNavegar
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Color del indicador de carga
          strokeWidth: 2, // Grosor del indicador
        )
            : GestureDetector(
          onTap: () async {
            setState(() {
              _isLoadingNavegar = true; // Iniciar el estado de carga
            });
            // Verificar conexión a Internet antes de navegar
            bool hasConnection = await connectionService.hasInternetConnection();
            setState(() {
              _isLoadingNavegar = false; // Terminar el estado de carga
            });
            if (hasConnection) {
              // Si hay conexión, ejecuta la función correspondiente
              if (_controller.navegadorSelecionado == 'waze') {
                _controller.botonNavegacionWaze();
              } else {
                _controller.botonNavegacionGoogleMaps();
              }
            } else {
              // Si no hay conexión, muestra un AlertDialog
              alertSinInternet();
            }
          },
          child: _controller.navegadorSelecionado == 'waze'
              ? Image.asset("assets/images/waze_azul.png")
              : Image.asset("assets/images/logo_google_maps.png"),
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

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: _controller.centerPosition,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        child: Card(
          shape: const CircleBorder(),
          color: blanco,
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              color: negro,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }

}
