
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import '../../../models/driver.dart';

class LoginController {

  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;


  Future? init(BuildContext context) {
    this.context = context;
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    return null;
  }


  void showSimpleAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void closeSimpleProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToRegisterPage() {
    Navigator.pushNamed(context, 'signup');
  }

  void goToAntesIniciarPage() {
    Navigator.pushNamedAndRemoveUntil(
        context, "antes_iniciar", (route) => false);
  }

  void goToForgotPassword() {
    Navigator.pushNamed(context, 'forgot_password');
  }

  void goToSelectTypeUser() {
    Navigator.pushNamed(context, 'select_type_user');
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty && password.isEmpty) {
      Snackbar.showSnackbar(context, key, 'No has ingresado tus credenciales');
      return;
    }
    if (email.isEmpty) {
      Snackbar.showSnackbar(
          context, key, 'Debes ingresar tu correo electrónico');
      return;
    }
    if (password.isEmpty) {
      Snackbar.showSnackbar(context, key, 'Debes ingresar tu contraseña');
      return;
    }
    if (password.length < 6) {
      Snackbar.showSnackbar(
          context, key, 'La contraseña debe tener mínimo 6 caracteres');
      return;
    }
    showSimpleAlertDialog(context, 'Espera un momento ...');
    try {
      bool isLoginSuccessful = await _authProvider.login(
          email, password, context);
      if (isLoginSuccessful) {
        Driver? driver = await _driverProvider.getById(
            _authProvider.getUser()!.uid);
        if (driver != null) {
          // Comprobar si el usuario ya está logueado en otro dispositivo
          bool isLoggedIn = await _driverProvider.checkIfUserIsLoggedIn(
              driver.id);
          if (isLoggedIn) {
            // Usar una copia local del contexto y verificar si sigue montado
            if (context.mounted) {
              Snackbar.showSnackbar(context, key,
                  'Este usuario ya está logueado en otro dispositivo.');
            }
            return; // No permitir el inicio de sesión
          }

          // Actualizar el estado de inicio de sesión en Firestore
          await _driverProvider.updateLoginStatus(driver.id, true);

          // Verificar si el usuario ya está logueado
          if (context.mounted) {
            _authProvider.checkIfUserIsLogged(context);
          }
        } else {
          if (context.mounted) {
            Snackbar.showSnackbar(context, key, 'Este usuario no es válido');
          }
          await _authProvider.signOut();
        }
      }
    } catch (error) {
      if (context.mounted) {
        Snackbar.showSnackbar(context, key, 'Error: $error');
      }
    } finally {
      if (context.mounted) {
        closeSimpleProgressDialog(context);
      }
    }
  }


}
