import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionManager {
  static Future<void> checkAndRequestLocationPermission(BuildContext context) async {
    var status = await Permission.locationAlways.status;

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      await _showPermissionDialog(context);
    }
  }

  static Future<void> _showPermissionDialog(BuildContext context) async {
    bool? isGranted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(
                Icons.location_on, // Ícono de ubicación
                color: Theme.of(context).primaryColor, // Color del ícono basado en el color primario de la app
                size: 40, // Tamaño del ícono
              ),
              const SizedBox(height: 10), // Espacio entre el ícono y el texto
              const Text(
                'Permisos de ubicación necesarios',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18), // Añadir un estilo más resaltado
                textAlign: TextAlign.center, // Centrar el texto
              ),
            ],
          ),
          content: const Text(
            'La aplicación necesita permisos de ubicación "TODO EL TIEMPO" para funcionar correctamente. '
                'Por favor, conceda estos permisos en la configuración de la aplicación.',
            textAlign: TextAlign.justify, // Ajustar el texto para que se vea mejor en el cuadro de diálogo
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Conceder permisos'),
              onPressed: () async {
                var status = await Permission.locationAlways.request();
                Navigator.of(context).pop(status == PermissionStatus.granted);
              },
            ),
          ],
        );

      },
    );

    // Si isGranted es null, significa que el diálogo se cerró sin tomar una decisión
    if (isGranted == null) {
      // Muestra nuevamente el diálogo para asegurarte de que el usuario tome una decisión
      await _showPermissionDialog(context);
    }
    // Si isGranted es false, significa que el usuario rechazó los permisos
    else if (isGranted == false) {
      // Muestra nuevamente el diálogo para darle otra oportunidad al usuario
      await _showPermissionDialog(context);
    }
    // Si isGranted es true, significa que el usuario otorgó los permisos
    else {
      // Continúa con tu lógica aquí...
    }
  }
}