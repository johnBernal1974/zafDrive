import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'driver_provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Mensaje recibido en segundo plano: ${message.messageId}');
  }
  // Procesa el mensaje recibido en segundo plano
}

class PushNotificationsProvider {
  late FirebaseMessaging _firebaseMessaging;
  final StreamController<Map<String, dynamic>> _streamController = StreamController<Map<String, dynamic>>.broadcast();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<Map<String, dynamic>> get message => _streamController.stream;

  PushNotificationsProvider() {
    _firebaseMessaging = FirebaseMessaging.instance;
    // Inicializa el manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void initPushNotifications(BuildContext context) {
    // Escucha los mensajes recibidos en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Mensaje recibido en primer plano: ${message.messageId}');
      }// Reproducir un sonido cuando se recibe un mensaje
      _playSound();
    });

    // Escucha los mensajes recibidos cuando la aplicación se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _streamController.sink.add(message.data);
      // Navegar a la página si es necesario
      // if (message.data['page'] == 'solicitud_servicio') {
      //   Navigator.pushNamed(context, 'map_driver');
      // }
    });
  }

  Future<void> _playSound() async {
    // Asegúrate de tener un archivo de sonido en tu proyecto
    try {
      await _audioPlayer.setAsset('assets/audio/alerta_servicio.mp3'); // Ajusta la ruta y el nombre del archivo
      _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error al reproducir el sonido: $e');
      }
    }
  }

  void saveToken(String idUser) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      Map<String, dynamic> data = {'token': token};
      DriverProvider driverProvider = DriverProvider();
      driverProvider.update(data, idUser);
    } else {
      if (kDebugMode) {
        print('Error al obtener el token de Firebase Messaging');
      }
    }
  }

  void dispose() {
    _streamController.close();
    _audioPlayer.dispose(); // No olvides liberar los recursos del reproductor
  }
}
