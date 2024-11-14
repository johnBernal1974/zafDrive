import 'package:flutter/material.dart';
import 'package:zafiro_conductores/src/colors/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InfoPermisosPage extends StatefulWidget {
  const InfoPermisosPage({super.key});

  @override
  State<InfoPermisosPage> createState() => _InfoPermisosPageState();
}

class _InfoPermisosPageState extends State<InfoPermisosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    ponerVistopermisosentrue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Deshabilita el botón de "Atrás"
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: blancoCards,
          title: const Text('Permisos Requeridos', style: TextStyle(color: negro)),
          automaticallyImplyLeading: false, // Oculta el botón de regreso
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/logo_zafiro-pequeño.png', width: 50)),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: const Text(
                  'Zafiro necesita para su correcto funcionamiento que aceptes los siguientes permisos en el momento que te sean solicitados:',
                  style: TextStyle(fontSize: 12, height: 1),
                ),
              ),
              const SizedBox(height: 20),
              // Permiso de localización
              Row(
                children: [
                  Icon(Icons.location_on, size: 30, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded( // Ajusta el contenido al espacio disponible
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permiso de localización',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.black), // Estilo general
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Es indispensable que concedas este permiso en la opción ',
                              ),
                              TextSpan(
                                text: '"TODO EL TIEMPO"',
                                style: TextStyle(fontWeight: FontWeight.bold), // Negrita
                              ),
                              TextSpan(
                                text: ', lo que permitirá que el usuario pueda ver tu ubicación en tiempo real.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.notifications, size: 30, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded( // Ajusta el contenido al espacio disponible
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Permiso de Notificaciones',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.black), // Estilo general
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Se necesita este permiso para informarte sobre ',
                              ),
                              TextSpan(
                                text: 'actualizaciones importantes',
                                style: TextStyle(fontWeight: FontWeight.bold), // Negrita
                              ),
                              TextSpan(
                                text: ' y te lleguen las solicitudes de servicio.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.battery_alert, size: 30, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded( // Ajusta el contenido al espacio disponible
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No optimización de batería',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.black), // Estilo general
                            children: <TextSpan>[
                              TextSpan(
                                text: 'La app debe estar exenta de la optimización de batería para ',
                              ),
                              TextSpan(
                                text: 'funcionar correctamente',
                                style: TextStyle(fontWeight: FontWeight.bold), // Negrita
                              ),
                              TextSpan(
                                text: ' en segundo plano y evitar que se cierre la aplicación.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recuerda:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Sin estos permisos tu aplicación no funcionará de la manera adecuada.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    // Obtener el UID del usuario actual
                    String? uid = _auth.currentUser?.uid;
                    if (uid != null) {
                      // Actualizar la base de datos
                      try {
                        await _firestore.collection('Drivers').doc(uid).update({
                          'info_permisos': true,
                        });
                        // Navegar a la siguiente página
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, 'antes_iniciar', (route) => false);
                        }
                      } catch (e) {
                        // Manejo de errores
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar la base de datos: $e')),
                          );
                        }
                      }
                    } else {
                      // Manejo de error si no hay usuario logueado
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay usuario autenticado.')),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Entendido',
                        style: TextStyle(
                          color: Colors.black, // Asegúrate de que sea un color válido
                          fontSize: 16, // Ajusta el tamaño de la fuente según tu diseño
                        ),
                      ),
                      SizedBox(width: 8), // Espacio entre el texto y el ícono
                      Icon(
                        Icons.double_arrow, // Ícono de doble flecha
                        color: Colors.black, // Asegúrate de que sea un color válido
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void ponerVistopermisosentrue() async{
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Actualizar la base de datos
      try {
        await _firestore.collection('Drivers').doc(uid).update({
          'info_permisos': true,
        });
      } catch (e) {
        // Manejo de errores
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la base de datos: $e')),
          );
        }
      }
    } else {
      // Manejo de error si no hay usuario logueado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado.')),
      );
    }
  }
}
