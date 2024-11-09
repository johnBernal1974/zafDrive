import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Helpers/SnackBar/snackbar.dart';
import '../../../../Helpers/SnackBar/snackbarVerde.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';


class ElegirNavegadorPage extends StatefulWidget {
  const ElegirNavegadorPage({super.key});

  @override
  State<ElegirNavegadorPage> createState() => _ElegirNavegadorPageState();
}

class _ElegirNavegadorPageState extends State<ElegirNavegadorPage> {

  late String navegador= "";
  late bool isVisiblewaze = false;
  late bool isVisibleGoogleMaps = false;
  late bool isVisibleUsoWaze = false;
  late bool isVisibleUsoGoogleMaps = false;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void initState()  {
   iniciarPreferencias();
    super.initState();
  }

  void iniciarPreferencias()async {
    SharedPreferences sharepreferences = await SharedPreferences.getInstance();
    String? seleccion= sharepreferences.getString('navegador');
    if(seleccion == null) {
      setState(() {
        sharepreferences.setString('navegador', 'googleMaps');
        isVisibleGoogleMaps= true;
        isVisibleUsoGoogleMaps = true;
      });
    }
    if(seleccion == 'waze'){
      setState(() {
        isVisiblewaze = true;
        isVisibleUsoWaze = true;
      });
    }
    if(seleccion == 'googleMaps'){
      setState(() {
        isVisibleGoogleMaps = true;
        isVisibleUsoGoogleMaps = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "Elegir navegador",
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: negro
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        alignment: Alignment.center,
        child: Column(
          children: [
          _textIndicaciones(),
            const Divider(color: grisMedio),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        _waze(),
                        Visibility(
                          visible: isVisiblewaze,
                          child: const Image(
                              height: 35.0,
                              width: 35.0,
                              image: AssetImage('assets/images/check_verde.png')),
                        ),
                      ],
                    ),
                    _textTypeUser('Waze'),
                    Visibility(
                      visible: isVisibleUsoWaze,
                        child: headerText(text: "(Seleccionado)", fontWeight: FontWeight.w500, color: negro))
                  ],
                ),
                Column(
                  children: [
                    Stack(
                      children: [
                        _googleMaps(),
                        Visibility(
                          visible: isVisibleGoogleMaps,
                          child: const Image(
                              height: 35.0,
                              width: 35.0,
                              image: AssetImage('assets/images/check_verde.png')),
                        ),
                      ],
                    ),
                    _textTypeUser('Google Maps'),
                    Visibility(
                        visible: isVisibleUsoGoogleMaps,
                        child: headerText(text: "(Seleccionado)", fontWeight: FontWeight.w500, color: negro)
                    )
                  ],
                ),
              ],
            ),
          ],
        )
      ),
    );
  }

  Widget _textTypeUser( String typeUser){
    return headerText(
      text: typeUser,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: negro,
    );
  }

  Widget _waze() {
    return GestureDetector(
      onTap: () async {
        // Captura el contexto antes de iniciar cualquier operación asíncrona.
        final currentContext = context;
        // Obtén SharedPreferences y guarda la selección
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('navegador', 'waze');
        String seleccion = sharedPreferences.getString('navegador') ?? "";
        // Actualiza el estado de la interfaz
        setState(() {
          if (!isVisiblewaze) {
            isVisibleUsoWaze = !isVisibleUsoWaze;
            SnackbarVerde.showSnackbarVerde(
                currentContext, key, 'Se ha seleccionado $seleccion como navegador');
          } else {
            Snackbar.showSnackbar(
                currentContext, key, 'Se ha descartado la selección');
          }
          isVisiblewaze = !isVisiblewaze;
          if (isVisibleGoogleMaps) {
            isVisibleGoogleMaps = !isVisibleGoogleMaps;
          }
          if (isVisibleUsoGoogleMaps) {
            isVisibleUsoGoogleMaps = !isVisibleUsoGoogleMaps;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
        child: const Image(
          height: 50.0,
          width: 50.0,
          image: AssetImage('assets/images/waze_azul.png'),
        ),
      ),
    );
  }


  Widget _googleMaps() {
    return GestureDetector(
      onTap: () async {
        // Captura el contexto antes de iniciar cualquier operación asíncrona.
        final currentContext = context;
        // Obtén SharedPreferences y guarda la selección
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('navegador', 'googleMaps');
        String seleccion = sharedPreferences.getString('navegador') ?? "";
        // Actualiza el estado de la interfaz
        setState(() {
          if (!isVisibleGoogleMaps) {
            isVisibleUsoGoogleMaps = !isVisibleUsoGoogleMaps;
            SnackbarVerde.showSnackbarVerde(
                currentContext, key, 'Se ha seleccionado $seleccion como navegador');
          } else {
            Snackbar.showSnackbar(
                currentContext, key, 'Se ha descartado la selección');
          }
          isVisibleGoogleMaps = !isVisibleGoogleMaps;
          if (isVisiblewaze) {
            isVisiblewaze = !isVisiblewaze;
          }
          if (isVisibleUsoWaze) {
            isVisibleUsoWaze = !isVisibleUsoWaze;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
        child: const Image(
          height: 50.0,
          width: 50.0,
          image: AssetImage('assets/images/logo_google_maps.png'),
        ),
      ),
    );
  }


  Widget _textIndicaciones(){
    return Container(
      alignment: Alignment.center,
      child: const Text('Puedes seleccionar aquí el navegador predeterminado. Este no podrá ser cambiado mientras te encuentres realizando un servicio.',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500, color: negro
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}
