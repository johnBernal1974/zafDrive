
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _checkConnectionAndAuthenticate();
  }

  void _checkConnectionAndAuthenticate() async {
    await connectionService.checkConnectionAndShowSnackbar(context, () async {
      bool isLoggedIn = await _authProvider.isUserLoggedIn();
      if (isLoggedIn) {
        if(context.mounted){
          _authProvider.checkIfUserIsLogged(context);
        }

      } else {
        // Si no está logueado, navega a la pantalla de login (LoginPage)
        _navigateToLoginPage();
      }
    });
  }

  void _navigateToLoginPage() {
    // Redirige a la página de login
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
        statusBarIconBrightness: Brightness.dark));

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
                    image: AssetImage('assets/images/imagen_zafiro_azul.png')
                ),
                Image(
                    height: 70.0,
                    width: 220.0,
                    image: AssetImage('assets/images/logo_zafiro-pequeño.png')
                ),
                Text('Conductores', style: TextStyle(fontWeight: FontWeight.w900, color: negro,fontSize: 26),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
