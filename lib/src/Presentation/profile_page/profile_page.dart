import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zafiro_conductores/src/Presentation/profile_page/profileController/profileController.dart';
import '../../colors/colors.dart';
import '../commons_widgets/headers/header_text/header_text.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();

   @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context, refresh);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: const Text("Mis datos", style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: negro,
        )),
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
        child: Container(
          margin: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _fotoPerfil(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Viajes\nrealizados',
                              style: TextStyle(color: primary, fontSize: 12),
                              textAlign: TextAlign.center, // Asegúrate de centrar el texto también
                            ),
                          ),
                          Text(
                            _controller.driver?.the30NumeroViajes.toString() ?? '',
                            style: const TextStyle(color: negro, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center, // Asegúrate de centrar el texto
                          ),
                        ],
                      ),

                    ],
                  )
                ],
              ),
              _textSubtitledatosPersonales(),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 5),
              _nombres(),
              _apellidos(),
              _tipoDocumento(),
              _identificacion(),
              _email(),
              _celular(),
              const SizedBox(height: 45),
              _textSubtitledatosVehiculo(),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 5),
              _placa(),
              _marca(),
              _color(),
              _modelo(),
              _tipoVehiculo(),
              _tipoServicio(),
              const SizedBox(height: 45),
              _textSubtitledocumentosVehiculo(),
              const Divider(height: 1, color: grisMedio),
              const SizedBox(height: 5),
              _tarjetaPropiedad(),
              _soat(),
              _vigenciasoat(),
              _tecno(),
              _vigenciatecno()
            ],
          ),
        ),

      ),
    );
  }

  void refresh() {
    setState(() {}); // Esto actualizará el widget
  }

  Widget _fotoPerfil() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(
          color: primary, // Color del borde
          width: 2, // Ancho del borde
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
    );
  }

  Widget _nombres(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Nombre:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the01Nombres ?? "", color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _apellidos(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Apellidos:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the02Apellidos ?? "", color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tipoDocumento(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Documento:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the04TipoDocumento ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _identificacion(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'No. Identificación:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the03NumeroDocumento ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _email(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Email:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the06Email ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }
  Widget _celular(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Celular:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the07Celular ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _placa(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Placa:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the18Placa ?? '', color: negro,fontSize: 20,fontWeight: FontWeight.w900),
      ],
    );
  }

  Widget _marca(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Marca:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the15Marca ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _color(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Color:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the16Color ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _modelo(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Modelo:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the17Modelo ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tipoVehiculo(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Tipo de vehículo:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the14TipoVehiculo ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tipoServicio(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Tipo de servicio:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the19TipoServicio ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }
  Widget _tarjetaPropiedad(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Tarjeta de propiedad:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the24NumeroTarjetaPropiedad ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _soat(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'No. Soat:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the20NumeroSoat ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _vigenciasoat(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Vigencia Soat:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the21VigenciaSoat ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _tecno(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'No. Tecnomecánica:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the22NumeroTecno ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _vigenciatecno(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        headerText( text: 'Vigencia Tecno:' , color: gris, fontSize: 14,fontWeight: FontWeight.w500),
        const SizedBox(width: 5),
        headerText( text: _controller.driver?.the23VigenciaTecno ?? '', color: negro,fontSize: 14,fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _textSubtitledatosVehiculo() {
    return headerText(
      text: _controller.isMoto ?  'Datos de la Moto' : 'Datos del Vehículo',
      color: negro,
      fontSize: 20,
      fontWeight: FontWeight.w900,
    );
  }

  Widget _textSubtitledocumentosVehiculo(){
    return headerText(
        text: _controller.isMoto ?  'Documentos de la Moto' : 'Documentos del vehículo',
        color: negro,
        fontSize: 20,
        fontWeight: FontWeight.w900
    );
  }
}

Widget _textSubtitledatosPersonales(){
  return const Text('Datos personales', style: TextStyle(
    color: negro, fontSize: 20, fontWeight: FontWeight.w900
      ));
}





