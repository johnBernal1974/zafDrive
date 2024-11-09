
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/conectivity_service.dart';
import '../../colors/colors.dart';
import '../commons_widgets/Buttons/rounded_button.dart';
import '../commons_widgets/headers/header_text/header_text.dart';


class SelectTypeUserPage extends StatefulWidget {
  const SelectTypeUserPage({super.key});

  @override
  State<SelectTypeUserPage> createState() => _SelectTypeUserPageState();
}

class _SelectTypeUserPageState extends State<SelectTypeUserPage> {
  late String rol= "";
  late bool isVisibleMoto = false;
  late bool isVisibleCarro = false;
  late bool isVisibleBoton = false;

  // Para verificación de internet
  final ConnectionService _connectionService = ConnectionService();
  bool isConnected = false; //** para validar el estado de conexión a internet
  StreamSubscription<ConnectivityResult>? _connectivitySubscription; // Suscripción para escuchar cambios en conectividad
  SnackBar? _snackBar; // Guardar el SnackBar en una variable

  @override
  void initState() {
    super.initState();
    checkConnectionAndShowSnackbar();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionAndShowSnackbar();
    });
  }

  // Método para verificar la conexión a Internet y mostrar el Snackbar si no hay conexión
  Future<void> checkConnectionAndShowSnackbar() async {
    bool connected = await _connectionService.hasInternetConnection();
    if (connected) {
      if (_snackBar != null) {
        // Si hay conexión y hay un SnackBar visible, lo oculta
        if(context.mounted){
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        _snackBar = null; // Limpiar la referencia del SnackBar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primary
        ),
        actions:  <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: const Image(
                width: 80.0,
                image: AssetImage('assets/images/logo_zafiro-pequeño.png')),
          )

        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(height: 50),
              _textTitulo(),

              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            _userCarro(),
                            Visibility(
                              visible: isVisibleCarro,
                              child: const Image(
                                  height: 60.0,
                                  width: 60.0,
                                  image: AssetImage('assets/images/check_verde.png')),
                            ),
                          ],
                        ),
                        _textTypeUser('Carro')
                      ],
                    ),

                    Column(
                      children: [
                        Stack(
                          children: [
                            _userMoto(),
                            Visibility(
                              visible: isVisibleMoto,
                              child: const Image(
                                  height: 60.0,
                                  width: 60.0,
                                  image: AssetImage('assets/images/check_verde.png')),
                            ),
                          ],
                        ),
                        _textTypeUser('Moto')
                      ],
                    ),
                  ],
                ),

              ),
              const Spacer(),
              Visibility(
              visible: isVisibleBoton,
              child: Container(
                  child: _btonSeguir())),
            ],
          )),
    );
  }

  Widget _textTypeUser( String typeUser){
    return headerText(
      text: typeUser,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: negroLetras,
    );
  }

  Widget _userCarro(){
    return GestureDetector(
        onTap: () async {
          SharedPreferences sharepreferences = await SharedPreferences.getInstance();
          sharepreferences.setString('rol', 'carro');
          setState(() {
            isVisibleCarro = !isVisibleCarro;
            if(!isVisibleCarro || !isVisibleMoto){
              isVisibleBoton = !isVisibleBoton;
            }
            if(isVisibleMoto = isVisibleMoto){
              isVisibleMoto = !isVisibleMoto;
            }
          });
        },
      child: Container(
        padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
        child: const Image(
            height: 110.0,
            width: 110.0,
            image: AssetImage('assets/images/carro_plateado.png')),
      ),
    );
  }

  Widget _userMoto(){
    return GestureDetector(
      onTap: () async {
        SharedPreferences sharepreferences = await SharedPreferences.getInstance();
        sharepreferences.setString('rol', 'moto');
        setState(() {
          isVisibleMoto = !isVisibleMoto;
          if(!isVisibleCarro || !isVisibleMoto){
            isVisibleBoton = !isVisibleBoton;
          }
          if(isVisibleCarro = isVisibleCarro){
            isVisibleCarro = !isVisibleCarro;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
        child: const Image(
            height: 110.0,
            width: 110.0,
            image: AssetImage('assets/images/moto.png')),
      ),
    );
  }

  Widget _textTitulo(){
    return headerText(
      text: '¿Que vas a conducir?',
      fontSize: 26,
      fontWeight: FontWeight.w900,
      color: negro,
    );
  }

  Widget _btonSeguir(){
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25, bottom: 50),
      child: createElevatedButton(
        labelButton: 'Continuar',
        labelFontSize: 18,
        color: primary,
        labelColor: blanco,
        func:() {
          _obtenerRol();
        }
      ),
    );
  }

  void _obtenerRol() async {
    SharedPreferences sharepreferences = await SharedPreferences.getInstance();
    String? rol = sharepreferences.getString('rol');

    // Asegurarse de que el widget esté montado antes de navegar
    if (!mounted) return;

    // Usa Future.microtask para evitar problemas de contexto
    Future.microtask(() {
      if (rol == 'carro') {
        Navigator.pushNamed(context, 'signup');
      } else {
        Navigator.pushNamed(context, 'signup_moto');
      }
    });
  }


  @override
  void dispose(){
    super.dispose();
    _connectivitySubscription?.cancel();
  }

}
