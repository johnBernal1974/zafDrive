import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../Helpers/Validators/FormValidators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../../splash_page/View/splash_page.dart';
import '../antes_iniciar_controller/antes_iniciar_controller.dart';

class AntesIniciarPage extends StatefulWidget {
  const AntesIniciarPage({super.key});

  @override
  State<AntesIniciarPage> createState() => _AntesIniciarPageState();
}

class _AntesIniciarPageState extends State<AntesIniciarPage> {
  final AntesIniciarController _controller = AntesIniciarController();
  late String formattedSaldo;
  late MyAuthProvider _authProvider;
  bool saldoRecarga = false;
  bool isAvisoSinSaldoVisible = false;
  String saldo = "";
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  final ConnectionService connectionService = ConnectionService();
  bool _isLoading = false;
  bool _isLoadingRecarga = false;


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      _controller.requestNotificationPermission();
      _authProvider = MyAuthProvider();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    formattedSaldo = FormatUtils.formatCurrency(_controller.driver?.the32SaldoRecarga ?? 0);
    return Scaffold(
      key: key,
      drawer: _drawer(),
      appBar: AppBar(
        backgroundColor: blancoCards,
        title: headerText(
          text: "Inicio",
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: negro,
        ),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: const Image(
                width: 80.0,
                image: AssetImage('assets/images/logo_zafiro-pequeño.png')),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primary,
                              width: 1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundColor: blanco,
                            backgroundImage: _controller.driver?.image != null
                                ? CachedNetworkImageProvider(_controller.driver!.image)
                                : null,
                            radius: 35,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              headerText(
                                text: _controller.driver?.the01Nombres ?? "",
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: negro,
                              ),
                              headerText(
                                text: _controller.driver?.the02Apellidos ?? "",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: negroLetras,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cajonSaldoRecarga(),
                        _botonRecargar()
                      ],
                    ),
                    _permisosUbicacion(),
                    const SizedBox(height: 40),
                    _buttonIngresar(context, connectionService),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void verificarRecarga(){
    int saldoRecarga = _controller.driver?.the32SaldoRecarga ?? 0;
        if(saldoRecarga <= 0){
      Snackbar.showSnackbar(context, key, 'Tu cuenta se encuentra sin saldo. Haz una recarga para poder ingresar');
    }else{
      Navigator.pushNamedAndRemoveUntil(context, "map_driver", (route) => false);
    }
  }

  void refresh() {
    setState(() {});
  }

  void _mostrarAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cierre de sesión',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: negro,
              fontWeight: FontWeight.bold,
            ),
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
                    onPressed: () {
                      _authProvider.signOut();
                      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const SplashPage()));
                    },
                    child: const Text(
                      'Sí',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: negro),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: negro),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _botonRecargar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.green, // Color verde
            Color(0xFF4CAF50), // Color verde más claro para el degradado
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Color de la sombra
            blurRadius: 12.0, // Desenfoque
            offset: const Offset(0, 6), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoadingRecarga
            ? null // Desactivar el botón si está cargando
            : () async {
          setState(() {
            _isLoadingRecarga = true; // Iniciar el estado de carga
          });

          // Verificar la conexión
          bool hasConnection = await connectionService.hasInternetConnection(); // Asegúrate de tener esta función en tu servicio

          setState(() {
            _isLoadingRecarga = false; // Terminar el estado de carga
          });

          if (hasConnection) {
            // Si hay conexión, navega a la página 'recargar'
            if(context.mounted){
              Navigator.pushNamed(context, 'recargar');
            }
          } else {
            // Si no hay conexión, muestra un AlertDialog
            alertSinInternet();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Hacer el fondo transparente
          elevation: 0, // Sin elevación del botón
          foregroundColor: blanco, // Color del texto y del icono
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Borde del botón
          ),
        ),
        icon: _isLoadingRecarga // Mostrar el icono o el indicador de carga
            ? Container() // No mostrar icono si está cargando
            : const Icon(Icons.double_arrow),
        label: _isLoadingRecarga // Mostrar el indicador de carga o el texto del botón
            ? const SizedBox(
          width: 20, // Ancho del indicador de carga
          height: 20, // Alto del indicador de carga
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(blanco), // Color del indicador
            strokeWidth: 2, // Grosor del indicador
          ),
        )
            : const Text(
          'Recargar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: blanco
          ),
        ),
      ),

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
                          color: primary,
                          width: 1,
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
                    ),
                  ),
                  Text(
                    _controller.driver?.the01Nombres ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blanco),
                    maxLines: 1,
                  ),
                  Text(
                    _controller.driver?.the02Apellidos ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: blanco),
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
            onTap: () {
              Navigator.pop(context);
              _mostrarAlertDialog(context);
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

  Widget _cajonSaldoRecarga() {
    // Determina el saldo de recarga, si es nulo o cero se asume que no hay saldo
    int saldoRecarga = _controller.driver?.the32SaldoRecarga ?? 0;
    // Determina el color del borde y el texto según el saldo de recarga
    Color borderColor = saldoRecarga <= 0 ? Colors.red : Colors.black;
    Color saldoColor = saldoRecarga <= 0 ? Colors.red : Colors.black;
    // Formatea el saldo de recarga con símbolo de pesos antes y separador de miles
    String formattedSaldo = '\$ ${NumberFormat('#,###', 'es_CO').format(saldoRecarga)}';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2, color: borderColor),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 5,
                color: Colors.grey,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Saldo de Recarga',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                formattedSaldo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: saldoColor,
                ),
              ),
              if (saldoRecarga <= 0) _avisoSinSaldo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avisoSinSaldo() {
    return headerText(text: '¡Sin Saldo!', fontSize: 12, fontWeight: FontWeight.w700, color: rojo);
  }

  Widget _permisosUbicacion() {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(top: 40, bottom: 5),
          child: Row(
            children: [
              const Icon(
                Icons.pin_drop_rounded,
                color: negro,
                size: 30,
              ),
              headerText(
                text: 'Permisos de Ubicación',
                color: negro,
                fontWeight: FontWeight.w800,
                textAling: TextAlign.left,
                fontSize: 16,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: headerText(
            text: 'Al dar clic en el boton INGRESAR, Zafiro recopila datos de ubicación para habilitar '
                'los mapas, seguir en tiempo real las rutas existentes durante un viaje, incluso cuando la aplicación está cerrada.',
            color: negroLetras,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            textAling: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buttonIngresar(BuildContext context, ConnectionService connectionService) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primary, // Color primario
            turquesa, // Color turquesa
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Color de la sombra
            blurRadius: 12.0, // Desenfoque
            offset: const Offset(0, 6), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading
            ? null // Desactivar el botón si está cargando
            : () async {
          setState(() {
            _isLoading = true; // Iniciar el estado de carga
          });
          // Verificar la conexión a Internet antes de ejecutar la acción
          bool hasConnection = await connectionService.hasInternetConnection();
          setState(() {
            _isLoading = false; // Terminar el estado de carga
          });
          if (hasConnection) {
            // Si hay conexión, ejecuta la acción
            verificarRecarga();
          } else {
            // Si no hay conexión, muestra un AlertDialog
            alertSinInternet();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Hacer el fondo transparente
          elevation: 0, // Sin elevación del botón
          foregroundColor: blanco, // Color del texto y del icono
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Borde del botón
          ),
        ),
        label: _isLoading // Mostrar el indicador de carga o el texto del botón
            ? const SizedBox(
          width: 20, // Ancho del indicador de carga
          height: 20, // Alto del indicador de carga
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(blanco), // Color del indicador
            strokeWidth: 2, // Grosor del indicador
          ),
        )
            : const Text(
          'Ingresar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: blanco
          ),
        ),
        icon: _isLoading ? Container() : const Icon(Icons.double_arrow), // Mostrar el icono solo si no está cargando
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
}
