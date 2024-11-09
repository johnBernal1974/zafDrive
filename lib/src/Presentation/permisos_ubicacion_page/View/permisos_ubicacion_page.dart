import 'package:flutter/material.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class PermisosUbicacionPage extends StatelessWidget {
  const PermisosUbicacionPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: blancoCards,
        iconTheme: const IconThemeData(color: negro, size: 26),
        title: headerText(
            text: "Permisos de ubicación",
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: negro
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
            child: Column(
              children: [
               Container(
                 margin: const EdgeInsets.only(bottom: 20),
                 child: headerText(
                   text: 'Zafiro es una aplicación diseñada para el transporte de personas y el envío de encomiendas, '
                       'la cual necesita recopilar datos sobre la ubicación tanto de los usuarios como de los conductores '
                       'para garantizar su correcto funcionamiento. En el caso de los conductores, es indispensable que la '
                       'aplicación acceda a la ubicación en segundo plano por los siguientes motivos:'
                 , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                 textAling: TextAlign.justify),
               ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: headerText(
                      text: 'Dado que los conductores suelen utilizar aplicaciones adicionales como Google Maps o Waze mientras '
                          'realizan sus labores de transporte y entrega de encomiendas, es crucial que Zafiro pueda acceder a su '
                          'ubicación en segundo plano. Esto permite que los conductores reciban notificaciones de solicitudes de '
                          'servicio cercanas, incluso si están utilizando otras aplicaciones, asegurando así un funcionamiento '
                          'eficiente y sin interrupciones.'
                      , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                      textAling: TextAlign.justify),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: headerText(
                      text: 'El acceso a la ubicación en segundo plano por parte de los conductores permite que estén siempre visibles '
                          'y disponibles para recibir solicitudes de transporte o encomiendas. Esto les ayuda a obtener más servicios y, '
                          'en consecuencia, aumentar sus ingresos, lo cual es uno de los principales objetivos de los conductores que '
                          'utilizan Zafiro.'
                      , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                      textAling: TextAlign.justify),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: headerText(
                      text: 'Una de las necesidades fundamentales de los usuarios al utilizar una plataforma de transporte es poder visualizar '
                          'en tiempo real las rutas que sigue el conductor que ha aceptado el servicio. Esta función no solo mejora la experiencia '
                          'del usuario, sino que también genera confianza y tranquilidad. Para ofrecer esta característica, es esencial que la '
                          'aplicación tenga acceso a la ubicación del conductor en segundo plano.'
                      , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                      textAling: TextAlign.justify),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: headerText(
                      text: 'La información de ubicación de los conductores se utiliza para que los usuarios puedan localizarlos y solicitar '
                          'sus servicios. Cuando la aplicación se cierra por completo, la función de ubicación en segundo plano solo se activa '
                          'si el conductor está en medio de un viaje. En cambio, si el conductor está a la espera de un nuevo servicio y cierra '
                          'la app, la función en segundo plano no se activa. Esta característica brinda al conductor la tranquilidad de que, una '
                          'vez que finalice su labor o cierre la aplicación, Zafiro dejará de recopilar datos sobre su ubicación.'
                      , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                      textAling: TextAlign.justify),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: headerText(
                      text: 'La información de ubicación se utiliza exclusivamente para la función principal de la aplicación y nunca se comparte '
                          'con terceros. Los datos de ubicación del conductor son accesibles únicamente mientras la aplicación está abierta, y '
                          'solo el usuario que solicita el servicio puede ver esta información, desde el momento en que realiza la solicitud hasta '
                          'que el viaje finaliza.'
                      , fontSize: 14, color: negro , fontWeight: FontWeight.w400,
                      textAling: TextAlign.justify),
                ),
              ],
            )),
      ),
    );

  }
}
