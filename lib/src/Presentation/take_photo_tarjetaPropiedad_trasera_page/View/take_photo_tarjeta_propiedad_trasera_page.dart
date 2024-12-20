
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/conectivity_service.dart';
import '../../../../providers/driver_provider.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';
import '../take_photo_tarjetaPropiedad_trasera_controller/take_photo_tarjetaPropiedad_trasera_controller.dart';

class TakePhotoTarjetaPropiedadTraseraPage extends StatefulWidget {
  const TakePhotoTarjetaPropiedadTraseraPage({super.key});

  @override
  State<TakePhotoTarjetaPropiedadTraseraPage> createState() => _TakePhotoTarjetaPropiedadTraseraPagePageState();
}

class _TakePhotoTarjetaPropiedadTraseraPagePageState extends State<TakePhotoTarjetaPropiedadTraseraPage> {

  late TakePhotoTarjetaPropiedadTraseraController _controller = TakePhotoTarjetaPropiedadTraseraController();
  File? imageFile;
  final ConnectionService connectionService = ConnectionService();
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;

  @override
  void initState() {
    super.initState();
    _controller = TakePhotoTarjetaPropiedadTraseraController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
      _authProvider = MyAuthProvider();
      _driverProvider = DriverProvider();
    });
  }

  void refresh(){
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
            text: "",
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: negro
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
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _textoTitulo(),
              _cajonFotoTarjetaPropiedadTrasera(),
              const SizedBox(height: 15),
              headerText(text: 'Indicaciones',fontSize: 18),
              _instruccionesFoto(),
              const SizedBox(height: 15,),
              _botonTomarFoto(),
              const SizedBox(height: 15),
              _continuarButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _cajonFotoTarjetaPropiedadTrasera() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(5),
      // Aplicar un borde al Container
      decoration: BoxDecoration(
        border: Border.all(
          color: primary, // Color del borde
          width: 1.0, // Ancho del borde
        ),
        borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
      ),
      child: Container(
        width: double.infinity, // Ancho del rectángulo
        height: 250, // Alto del rectángulo
        decoration: BoxDecoration(
          color: blancoCards,
          borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0), // Radio de los bordes
          child: Stack(
            children: [
              if (_controller.pickedFile != null)
                Positioned.fill(
                  child: Image.file(
                    File(_controller.pickedFile!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              if (_controller.pickedFile == null || _controller.pickedFile?.name == 'asd')
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/tarjeta_trasera.png",
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonTomarFoto() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: ElevatedButton(
        onPressed: () {
          _controller.takePicture();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Color del botón
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, color: blanco, size: 16), // Icono de cámara
            SizedBox(width: 8), // Espacio entre el icono y el texto
            Text(
              'Tomar Foto',
              style: TextStyle(fontSize: 16, color: blanco),
            ),
          ],
        ),
      ),
    );
  }

  Widget _continuarButton() {
    bool hasPhoto = _controller.pickedFile != null;
    return Visibility(
      visible: hasPhoto,
      child: ElevatedButton(
        onPressed: () {
          // Verificar conexión a Internet antes de ejecutar la acción
          connectionService.hasInternetConnection().then((hasConnection) {
            if (hasConnection) {
              // Llama a _mostrarCajonDeBusqueda inmediatamente
              _controller.guardarFotoTarjetaPropiedadTrasera();
              updateVerifyStatus();
            } else {
              // Llama a alertSinInternet inmediatamente si no hay conexión
              alertSinInternet();
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: azulOscuro,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.double_arrow, color: blanco, size: 16),
            SizedBox(width: 8),
            Text(
              'Subir foto',
              style: TextStyle(fontSize: 16, color: blanco),
            ),
          ],
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

  Widget _instruccionesFoto(){
    return headerText(
        text: 'Por favor toma la foto de tu documento, sin flash y con el celular en posicion vertical',
        fontSize: 14,
        color: negroLetras,
        fontWeight: FontWeight.w500
    );
  }
  void updateVerifyStatus() async {
    Map<String, dynamic> data = {
      'Verificacion_Status': 'Procesando'
    };
    await _driverProvider.update(data, _authProvider.getUser()!.uid);
  }

  Widget _textoTitulo(){
    return headerText(
        text: 'Foto tarjeta de propiedad parte trasera',
        fontSize: 16,
        color: negro,
        fontWeight: FontWeight.w700
    );
  }

}
