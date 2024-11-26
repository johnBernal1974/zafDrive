import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../colors/colors.dart';
import '../../login_page/View/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late MyAuthProvider _authProvider;
  final ConnectionService connectionService = ConnectionService();

  @override
  void initState() {
    super.initState();
    _authProvider = MyAuthProvider();
    _initializeApp();
  }

  /// Inicialización de la app con validaciones necesarias
  void _initializeApp() async {
    await connectionService.checkConnectionAndShowSnackbar(context, () async {
      await _checkPermissions();
      bool isLoggedIn = await _authProvider.isUserLoggedIn();

      if (isLoggedIn) {
        if (context.mounted) {
          _authProvider.checkIfUserIsLogged(context);
        }
      } else {
        _navigateToLoginPage();
      }
    });
  }

  /// Verificar y solicitar permisos necesarios
  Future<void> _checkPermissions() async {
    // Verificar permisos de ubicación
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      locationPermission = await Geolocator.requestPermission();
    }

    if (locationPermission == LocationPermission.deniedForever) {
      _showPermissionDialog(
        title: "Permiso de ubicación requerido",
        message:
        "Por favor, habilita los permisos de ubicación desde la configuración de tu dispositivo para continuar.",
      );
      return;
    }

    // Verificar y solicitar permiso para ignorar optimizaciones de batería
    if (!(await Permission.ignoreBatteryOptimizations.isGranted)) {
      bool granted = await Permission.ignoreBatteryOptimizations.request().isGranted;
      if (!granted) {
        _showPermissionDialog(
          title: "Permiso de batería requerido",
          message:
          "Para un mejor funcionamiento de la aplicación, permite que esta ignore las restricciones de batería.",
        );
      }
    }
  }

  /// Mostrar un diálogo para permisos denegados
  void _showPermissionDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  /// Navegar a la página de inicio de sesión
  void _navigateToLoginPage() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: blancoCards,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: const Column(
              children: [
                Image(
                  height: 70.0,
                  width: 70.0,
                  image: AssetImage('assets/images/imagen_zafiro_azul.png'),
                ),
                Image(
                  height: 70.0,
                  width: 220.0,
                  image: AssetImage('assets/images/logo_zafiro-pequeño.png'),
                ),
                Text(
                  'Conductores',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: negro,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
