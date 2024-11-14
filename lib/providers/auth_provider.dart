
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../src/colors/colors.dart';
import 'driver_provider.dart';
import 'package:zafiro_conductores/src/models/driver.dart';

class MyAuthProvider {
  late FirebaseAuth _firebaseAuth;
  final DriverProvider _driverProvider = DriverProvider();

  MyAuthProvider(){
    _firebaseAuth = FirebaseAuth.instance;
  }

  BuildContext? get context => null;



  Future<bool> login(String email, String password, BuildContext context) async {
    String? errorMessage;

    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (error){
      errorMessage = _getErrorMessage(error.code);
      if(context.mounted){
        showSnackbar(context, errorMessage);
      }
      return false;
    }
    return true;
  }

  String _getErrorMessage(String errorCode) {
    // Mapeo de los códigos de error a mensajes en español
    Map<String, String> errorMessages = {
      'user-not-found': 'Usuario no encontrado. Verifica tu correo electrónico.',
      'wrong-password': 'Contraseña incorrecta. Inténtalo de nuevo.',
      'invalid-email': 'La dirección de correo electrónico no tiene el formato correcto.',
      'user-disabled': 'La cuenta de usuario ha sido deshabilitada.',
      'invalid-credential': 'Las credenciales proporcionadas no son válidas.',
      'network-request-failed': 'Sin señal. Revisa tu conexión de INTERNET.',
    };

    return errorMessages[errorCode] ?? 'Error desconocido';
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: rojo,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  User? getUser(){
    return _firebaseAuth.currentUser;
  }

  void checkIfUserIsLogged(BuildContext? context) {
    if (context == null) return; // Si el contexto es nulo, salimos del método

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (!context.mounted) return; // Verificamos que el contexto esté montado al inicio

      if (user != null) {
        if (!user.emailVerified) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'email_verification_page', (route) => false);
          }
          return;
        }

        DriverProvider driverProvider = DriverProvider();
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        Driver? driver = await driverProvider.getById(userId);

        if (driver != null) {
          // Verificación inicial de is_working
          bool isWorking = driver.the00_is_working;
          String ultimoCliente = driver.the00_ultimo_cliente;

          if (isWorking && context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'travel_map_page',
                  (route) => false,
              arguments: ultimoCliente,
            );
            return;
          }

          // Verificar estado de verificación del conductor
          String? verificationStatus = await driverProvider.getVerificationStatus();
          if ((verificationStatus == 'Procesando' || verificationStatus == 'corregida') && context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
            return;
          }

          if (verificationStatus == 'bloqueado' && context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'bloqueo_page', (route) => false);
            return;
          }

          // Verificación de fotos
          List<Map<String, dynamic>> fotoVerificaciones = [
            {'resultado': await driverProvider.verificarFotoPerfil(), 'pagina': 'take_foto_perfil'},
            {'resultado': await driverProvider.verificarFotoCedulaDelantera(), 'pagina': 'take_photo_cedula_delantera_page'},
            {'resultado': await driverProvider.verificarFotoCedulaTrasera(), 'pagina': 'take_photo_cedula_trasera_page'},
            {'resultado': await driverProvider.verificarFotoTarjetaPropiedadDelantera(), 'pagina': 'take_photo_tarjeta_propiedad_delantera_page'},
            {'resultado': await driverProvider.verificarFotoTarjetaPropiedadTrasera(), 'pagina': 'take_photo_tarjeta_propiedad_trasera_page'}
          ];

          for (var verificacion in fotoVerificaciones) {
            if ((verificacion['resultado'] == "" || verificacion['resultado'] == "rechazada") && context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, verificacion['pagina'], (route) => false);
              return;
            }
          }

          // Verificación de info_permisos
          bool infoPermisos = driver.info_permisos;
          if (!infoPermisos && context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'info_permisos', (route) => false);
            return;
          }

          // Si pasa todas las verificaciones y no está trabajando, redirigir a 'antes_iniciar'
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'antes_iniciar', (route) => false);
          }
        } else if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'antes_iniciar', (route) => false);
        }
      } else if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
      }
    });
  }

  void verificarFotosCedulaDelantera(BuildContext? context) {
    // Asegurarse de que el contexto no sea nulo antes de proceder
    if (context == null) {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
      return; // Salir del método si el contexto es nulo
    }

    // Si el contexto es válido, procedemos con la lógica
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DriverProvider driverProvider = DriverProvider();

        // Verificar si la foto de la cédula delantera ha sido verificada
        String? fotoCedulaDelanteraVerificada = await driverProvider.verificarFotoCedulaDelantera();

        // Verificar si la foto está verificada o rechazada
        if (fotoCedulaDelanteraVerificada == "" || fotoCedulaDelanteraVerificada == "rechazada") {
          // Solo navegar si el contexto está montado
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_delantera_page', (route) => false);
          }
        } else {
          // Si la foto ya está verificada, navegar a la página siguiente
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
          }
        }
      } else {
        // Si el usuario no está autenticado, navegar a la página de login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      }
    });
  }


  void verificarFotosCedulaTrasera(BuildContext? context) {
    // Asegurarse de que el contexto no sea nulo antes de proceder
    if (context == null) {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
      return; // Salir del método si el contexto es nulo
    }

    // Si el contexto es válido, procedemos con la lógica
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DriverProvider driverProvider = DriverProvider();
        String? fotoCedulaTraseraVerificada = await driverProvider.verificarFotoCedulaTrasera();

        // Verificar si la foto está verificada o rechazada
        if (fotoCedulaTraseraVerificada == "" || fotoCedulaTraseraVerificada == "rechazada") {
          // Solo navegar si el contexto está montado
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_cedula_trasera_page', (route) => false);
          }
        } else {
          // Si la foto ya está verificada, navegar a la página de verificación de identidad
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
          }
        }
      } else {
        // Si el usuario no está autenticado, navegar a la página de login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      }
    });
  }


  void verificarFotosTarjetaPropiedadDelantera(BuildContext? context) {
    // Asegurarse de que el contexto no sea nulo antes de proceder
    if (context == null) {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
      return; // Salir del método si el contexto es nulo
    }

    // Si el contexto es válido, procedemos con la lógica
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DriverProvider driverProvider = DriverProvider();
        String? fotoTarjetaPropiedadDelanteraVerificada = await driverProvider.verificarFotoTarjetaPropiedadDelantera();

        // Verificar si la foto está verificada o rechazada
        if (fotoTarjetaPropiedadDelanteraVerificada == "" || fotoTarjetaPropiedadDelanteraVerificada == "rechazada") {
          // Solo navegar si el contexto está montado
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_tarjeta_propiedad_delantera_page', (route) => false);
          }
        } else {
          // Si la foto ya está verificada, navegar a la página de la foto trasera
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_tarjeta_propiedad_trasera_page', (route) => false);
          }
        }
      } else {
        // Si el usuario no está autenticado, navegar a la página de login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      }
    });
  }


  void verificarFotosTarjetaPropiedadTrasera(BuildContext? context) {
    // Asegurarse de que el contexto no sea nulo antes de proceder
    if (context == null) {
      if (kDebugMode) {
        print('El contexto es nulo');
      }
      return; // Salir del método si el contexto es nulo
    }

    // Si el contexto es válido, procedemos con la lógica
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DriverProvider driverProvider = DriverProvider();
        String? fotoTarjetaPropiedadTraseraVerificada = await driverProvider.verificarFotoTarjetaPropiedadTrasera();

        // Verificar si la foto está verificada o rechazada
        if (fotoTarjetaPropiedadTraseraVerificada == "" || fotoTarjetaPropiedadTraseraVerificada == "rechazada") {
          // Solo navegar si el contexto está montado
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'take_photo_tarjeta_propiedad_trasera_page', (route) => false);
          }
        } else {
          // Si la foto ya está verificada, navegar a la página de verificación de identidad
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, 'verifying_identity', (route) => false);
          }
        }
      } else {
        // Si el usuario no está autenticado, navegar a la página de login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        }
      }
    });
  }


  void checkIfUserIsLoggedLoginPage(BuildContext context){
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user != null){
        Navigator.pushNamedAndRemoveUntil(context, "antes_iniciar", (route) => false);
      }
    });
  }

  Future<bool> signUp(String email, String password) async {
    String? errorMessage;

    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(error){
      errorMessage = error.code;
      if (kDebugMode) {
        print('ErrorMessage2: $errorMessage');
      }
      rethrow;
    }
    return true;
  }

  Future<void> signOut() async {
    String? userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      // Actualizar el estado de inicio de sesión a false en Firestore
      await _driverProvider.updateLoginStatus(userId, false);
    }
    // Cerrar sesión en Firebase Auth
    await _firebaseAuth.signOut();
  }

}
