import 'dart:async';
import 'dart:io'; // Para verificar la conexión a Internet
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Para el SnackBar
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart'; // Paquete para verificar el tipo de red

class ConnectionService {
  bool _isSnackBarVisible = false; // Estado para manejar la visibilidad del SnackBar
  bool isConnected = true;
  ConnectivityResult _connectionType = ConnectivityResult.none; // Almacena el tipo de conexión (Wi-Fi, móvil, etc.)

  // Verificar si hay conexión a Internet
  Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } on SocketException catch (_) {
      if (kDebugMode) {
        print("No hay conexión a Internet (SocketException)");
      }
      return false;
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print("No hay conexión a Internet (TimeoutException)");
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Otro error al intentar conectarse a Internet: $e");
      }
      return false;
    }
  }

  // Verificar si el servicio está disponible
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtener el tipo de conexión (Wi-Fi, móvil, etc.)
  Future<void> getConnectionType() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _connectionType = connectivityResult;
  }

  // Mostrar un SnackBar y mantenerlo visible hasta que haya conexión
  void showPersistentSnackBar(BuildContext context, VoidCallback onConnectionRestored) {
    if (_isSnackBarVisible) return; // Evitar mostrar si ya está visible

    const snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white),
          SizedBox(width: 8),
          Text('No tienes conexión a Internet.', style: TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(days: 1), // Mantenerlo visible indefinidamente
    );

    // Mostrar el SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _isSnackBarVisible = true; // Marcar el SnackBar como visible

    // Comenzar a verificar la conexión periódicamente
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (await hasInternetConnection()) {
        if(context.mounted){
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        _isSnackBarVisible = false; // Marcar el SnackBar como no visible
        onConnectionRestored(); // Llama al callback
        timer.cancel(); // Detener el temporizador
      }
    });
  }


  // Método principal que puedes usar en los controladores para verificar conexión
  Future<void> checkConnectionAndShowSnackbar(BuildContext context, VoidCallback onConnectionRestored) async {
    await getConnectionType();
    // Verificar la conectividad y si hay acceso a Internet real
    isConnected = await hasInternetConnection();
    if (isConnected) {
      if (await isServiceAvailable()) {
        onConnectionRestored();
      } else {
        if(context.mounted){
          showPersistentSnackBar(context, onConnectionRestored); // Muestra el SnackBar si el servicio no está disponible
        }
      }
    } else {
      if(context.mounted){
        showPersistentSnackBar(context, onConnectionRestored); // Muestra el SnackBar si no hay conexión
      }
    }
  }

}
