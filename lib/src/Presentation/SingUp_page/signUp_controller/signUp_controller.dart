
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Helpers/Dates/DateHelpers.dart';
import '../../../../Helpers/My_progress_dialog/myProgressDialog.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/driver_provider.dart';
import 'package:zafiro_conductores/src/models/driver.dart';

class SignUpController{

 late BuildContext  context;
 late Function refresh;
 GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  TextEditingController nombresController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController numeroDocumentoController = TextEditingController();
  TextEditingController celularController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailConfirmarController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmarController = TextEditingController();
  TextEditingController placaController = TextEditingController();

  String marca= "";
  String color= "";
  String modelo= "";
  String tipoVehiculo= "";
  String tiposervicio= "";
  String tipoDocumento= "";
  String fechaExpedicion= "";
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  late ProgressDialog _progressDialog;

 Future? init (BuildContext context, Function refresh) async {
  this.context = context;
  this.refresh = refresh;
  _authProvider = MyAuthProvider();
  _driverProvider = DriverProvider();
  iniciarPreferencias();
  _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espera un momento ...')!;
  return null;
  }

  void iniciarPreferencias() async {
    SharedPreferences sharepreferences = await SharedPreferences.getInstance();
    tipoDocumento= sharepreferences.getString('tipoDoc') ?? "Cédula de Ciudadanía";
    marca= sharepreferences.getString('marca') ?? "Chevrolet";
    color= sharepreferences.getString('color') ?? "Gris";
    modelo= sharepreferences.getString('modelo') ?? "2024";
    tipoVehiculo= sharepreferences.getString('tipoVehiculo') ?? "Automovil";
    tiposervicio= sharepreferences.getString('tipoServicio') ?? "Particular";
    fechaExpedicion= sharepreferences.getString('fechaExpedicion') ?? "";
  }

  void borrarPref() async {
    SharedPreferences sharepreferences = await SharedPreferences.getInstance();
    sharepreferences.remove('tipoDoc');
    sharepreferences.remove('marca');
    sharepreferences.remove('color');
    sharepreferences.remove('modelo');
    sharepreferences.remove('tipoVehiculo');
    sharepreferences.remove('tipoServicio');
    sharepreferences.remove('fechaExpedicion');
  }

 void _goTakeFotoPerfil(){
   Navigator.pushNamed(context, 'take_foto_perfil');
 }

  void signUp() async {
    iniciarPreferencias();
    String nombres= nombresController.text;
    String apellidos= apellidosController.text;
    String numeroDocumento= numeroDocumentoController.text;
    String celular= celularController.text;
    String email= emailController.text.trim();
    String emailConfirmar= emailConfirmarController.text.trim();
    String password= passwordController.text.trim();
    String passwordConfirmar= passwordConfirmarController.text.trim();
    String placa= placaController.text;
    if(nombres.isEmpty && apellidos.isEmpty && numeroDocumento.isEmpty && celular.isEmpty && email.isEmpty
        && emailConfirmar.isEmpty && password.isEmpty && passwordConfirmar.isEmpty && placa.isEmpty){
      Snackbar.showSnackbar(context, key, 'Todos los campos estan vacios');
      return;
    }
    if(nombres.isEmpty ){
     Snackbar.showSnackbar(context, key, "El campo 'Nombres' está vacio");
      return;
    }
    if(apellidos.isEmpty){
      Snackbar.showSnackbar(context, key, "El campo 'Apellidos' está vacio");
      return;
    }
    if(numeroDocumento.isEmpty ){
      Snackbar.showSnackbar(context, key, "El campo 'Número de identificación' está vacio");
      return;
    }
    if(celular.isEmpty ){
      Snackbar.showSnackbar(context, key, "El campo 'Celular' está vacio");
      return;
    }

    if(email.isEmpty){
      Snackbar.showSnackbar(context, key,  "El campo 'Correo electrónico' está vacio");
      return;
    }
    if(emailConfirmar.isEmpty){
      Snackbar.showSnackbar(context, key,  "El campo 'Confirmar el Correo electrónico' está vacio");
      return;
    }
    if(password.isEmpty){
      Snackbar.showSnackbar(context, key,  "El campo 'Crear contraseña' está vacio");
      return;
    }
    if(passwordConfirmar.isEmpty){
      Snackbar.showSnackbar(context, key,  "El campo 'Confirmar contraseña' está vacio");
      return;
    }
    if(placa.isEmpty){
      Snackbar.showSnackbar(context, key,  "El campo 'Placa' está vacio");
      return;
    }
    if(passwordConfirmar != password){
      Snackbar.showSnackbar(context, key, 'Las contraseñas no coinciden');
      return;
    }
    if(celular.length < 10){
      Snackbar.showSnackbar(context, key, 'El número de celular no es un número válido.');
      return;
    }
    if(numeroDocumento.length < 7){
      Snackbar.showSnackbar(context, key, 'El número de identidad no es un número válido.');
      return;
    }
    if(password.length < 6){
      Snackbar.showSnackbar(context, key, 'La contraseña debe tener mínimo 6 caracteres');
      return;
    }
    RegExp placaRegex = RegExp(r'^[a-zA-Z]{3}\d{3}$');
    if (!placaRegex.hasMatch(placa)) {
      Snackbar.showSnackbar(context, key, 'El número de placa es incorrecto');
      return;
    }
    if(email != emailConfirmar){
      Snackbar.showSnackbar(context, key, 'Las direcciones de correo no coinciden');
      return;
    }
    _progressDialog.show();
    try{
     bool isSignUp =  await _authProvider.signUp(email, password);
     if(isSignUp){
        Driver driver = Driver(
            id: _authProvider.getUser()!.uid,
            rol: "carro",
            the01Nombres: nombres,
            the02Apellidos: apellidos,
            the03NumeroDocumento: numeroDocumento,
            the04TipoDocumento: tipoDocumento,
            the05FechaExpedicionDocumento: fechaExpedicion,
            the06Email: email,
            the07Celular: celular,
            the08FechaNacimiento: "",
            the09Genero: "",
            the10FechaRegistro: DateHelpers.getStartDate(),
            the11EstaActivado: false,
            the12FechaActivacion: "",
            the13NombreActivador: "",
            the14TipoVehiculo: tipoVehiculo,
            the15Marca: marca,
            the16Color: color,
            the17Modelo: modelo,
            the18Placa: placa,
            the19TipoServicio: tiposervicio,
            the20NumeroSoat: "",
            the21VigenciaSoat: "",
            the22NumeroTecno: "",
            the23VigenciaTecno: "",
            the24NumeroTarjetaPropiedad: "",
            the25CedulaDelanteraFoto: "",
            the26CedulaTraseraFoto: "",
            the27TarjetaPropiedadDelanteraFoto: "",
            the28TarjetaPropiedadTraseraFoto: "",
            the29FotoPerfil: "",
            the30NumeroViajes: 0,
            the31Calificacion: 0,
            the321SaldoAnteriorInfo: 10000,
            the32SaldoRecarga: 10000,
            the33FechaUltimaRecarga: "",
            the34NuevaRecarga: 0,
            the35NuevaRecargaInfo: "0",
            the36FechaNuevaRecarga: "",
            the37RecargaRedimir: 0,
            the38EstaBloqueado: false,
            the39EstaConectado: false,
            the40NumeroCancelaciones: 0,
            the41SuspendidoPorCancelaciones: false,
            token: "",
            image: "",
            fotoCedulaDelantera: "",
            fotoCedulaTrasera: "",
            verificacionStatus: "",
            fotoTarjetaPropiedadDelantera: "",
            fotoTarjetaPropiedadTrasera: "",
            the00_is_active: false,
            the00_is_working: false,
            the00_ultimo_cliente: '',
            ceduladelanteraTomada: false,
            cedulatraseraTomada: false,
            tarjetadelanteraTomada: false,
            tarjetatraseraTomada: false,
            licenciaCategoria: "",
            licenciaVigencia: "",
            fotoPerfilTomada: false,
            info_permisos: false
        );
       await _driverProvider.create(driver);
        _progressDialog.hide();
        actualizarEstadoARegistrado ();
        _goTakeFotoPerfil();
        borrarPref();
     }else{
       _progressDialog.hide();
     }
    }catch (error) {
      _progressDialog.hide();
      if (kDebugMode) {
        print('Error durante el registro: $error');
      }
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          Snackbar.showSnackbar(key.currentContext!, key,
              'El correo electrónico ya está en uso por otra cuenta.');
        } else {
          Snackbar.showSnackbar(key.currentContext!, key,
              'Ocurrió un error durante el registro. Por favor, inténtalo nuevamente.');
        }
      } else {
        Snackbar.showSnackbar(key.currentContext!, key,
            'Ocurrió un error durante el registro. Por favor, inténtalo nuevamente.');
      }
    }
  }
 void actualizarEstadoARegistrado () async {
   Map<String, dynamic> data = {
     'Verificacion_Status': "registrado"};
   await _driverProvider.update(data, _authProvider.getUser()!.uid);
 }

}

