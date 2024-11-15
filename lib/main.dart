
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zafiro_conductores/providers/push_notifications_provider.dart';
import 'package:zafiro_conductores/src/Presentation/Forgot_PasswordPage/forgot_password_page.dart';
import 'package:zafiro_conductores/src/Presentation/Select_type_user_page/Select_type_user_page.dart';
import 'package:zafiro_conductores/src/Presentation/SingUpMoto_page/View/singUpMoto_page.dart';
import 'package:zafiro_conductores/src/Presentation/SingUp_page/View/singUp_page.dart';
import 'package:zafiro_conductores/src/Presentation/antes_inicar_page/View/antes_inicar_page.dart';
import 'package:zafiro_conductores/src/Presentation/bloqueo_page/bloqueo_page.dart';
import 'package:zafiro_conductores/src/Presentation/compartir_aplicacion_page/View/compartir_aplicacion_page.dart';
import 'package:zafiro_conductores/src/Presentation/contactanos_page/View/contactanos_page.dart';
import 'package:zafiro_conductores/src/Presentation/elegir_navegador_page/View/elegir_navegador.dart';
import 'package:zafiro_conductores/src/Presentation/eliminar_Cuenta_page/eliminar_cuenta_page.dart';
import 'package:zafiro_conductores/src/Presentation/email_verificationPage/email_verification_page.dart';
import 'package:zafiro_conductores/src/Presentation/historial_recargas_page/View/historial_recargas.dart';
import 'package:zafiro_conductores/src/Presentation/historial_viajes_page/View/historial_viajes_page.dart';
import 'package:zafiro_conductores/src/Presentation/info_permisos_page.dart';
import 'package:zafiro_conductores/src/Presentation/login_page/View/login_page.dart';
import 'package:zafiro_conductores/src/Presentation/map_driver_page/View/map_driver_page.dart';
import 'package:zafiro_conductores/src/Presentation/permisos_ubicacion_page/View/permisos_ubicacion_page.dart';
import 'package:zafiro_conductores/src/Presentation/politicas_de_privacidad_page/View/politicas_de_privacidad.dart';
import 'package:zafiro_conductores/src/Presentation/profile_page/profile_page.dart';
import 'package:zafiro_conductores/src/Presentation/recargar_page/View/recargar_page.dart';
import 'package:zafiro_conductores/src/Presentation/solicitud_servicio_page/solicitud_servicio_page.dart';
import 'package:zafiro_conductores/src/Presentation/splash_page/View/splash_page.dart';
import 'package:zafiro_conductores/src/Presentation/take_Photo_Cedula_Trasera/View/take_photo_cedula_trasera_page.dart';
import 'package:zafiro_conductores/src/Presentation/take_foto_perfil/take_foto_perfil.dart';
import 'package:zafiro_conductores/src/Presentation/take_photo_cedula_delantera/View/take_photo_cedula_delantera_page.dart';
import 'package:zafiro_conductores/src/Presentation/take_photo_tarjetaPropiedad_delantera_page/View/take_photo_tarjeta_propiedad_delantera_page.dart';
import 'package:zafiro_conductores/src/Presentation/take_photo_tarjetaPropiedad_trasera_page/View/take_photo_tarjeta_propiedad_trasera_page.dart';
import 'package:zafiro_conductores/src/Presentation/travel_calification_page/View/travel_calification_page.dart';
import 'package:zafiro_conductores/src/Presentation/travel_map_page/View/travel_map_page.dart';
import 'package:zafiro_conductores/src/Presentation/verifying_identity_page/View/verifying_identity_page.dart';
import 'Helpers/background_locator.dart';
import 'Helpers/events.dart';
import 'src/colors/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../Helpers/event_manager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar variables de entorno del archivo .env
  await dotenv.load(fileName: ".env");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeService();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  registerLocationUpdateTask();
  runApp(MyApp());
}

// Inicializa el servicio en segundo plano
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  // Configurar el servicio
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // Función a ejecutar al iniciar el servicio
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService(); // Iniciar el servicio en segundo plano
}

// Función que se ejecuta al iniciar el servicio
Future<bool> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Actualizando tu ubicación",
      content: "El servicio de ubicación está activo en segundo plano.",
    );
  }
  return true;
}

// Función que se ejecuta en segundo plano en iOS
Future<bool> onIosBackground(ServiceInstance service) async {
  return true; // Retornar true para indicar que el servicio se ha iniciado correctamente
}
// // Maneja los mensajes de Firebase en segundo plano
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   EventManager.sendEvent(OpenPageEvent('map_driver'));
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final PushNotificationsProvider pushNotificationsProvider = PushNotificationsProvider();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    pushNotificationsProvider.initPushNotifications(context);

    EventManager.listenEvent((event) {
      if (event is OpenPageEvent) {
        navigatorKey.currentState?.pushNamed(event.pageName);
      }
    });

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    createNotificationChannel();
    listenForNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Método que detecta los cambios en el ciclo de vida de la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      stopBackgroundServiceAndRemoveNotification();
    }
  }

  // Detiene el servicio en segundo plano y elimina la notificación
  void stopBackgroundServiceAndRemoveNotification() async {
    final service = FlutterBackgroundService();
    service.invoke('stop'); // Detiene el servicio en segundo plano
    await flutterLocalNotificationsPlugin.cancelAll(); // Elimina la notificación persistente
  }

  void createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void listenForNotifications() {
    pushNotificationsProvider.message.listen((data) {
      _showNotification(data);
      //Maneja la navegación según el tipo de notificación recibida
      //navigatorKey.currentState?.pushNamed('map_driver', arguments: data);
    });
  }

  Future<void> _showNotification(Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // El mismo ID del canal
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alerta_servicio'), // Nombre del archivo de sonido sin extensión
      playSound: true,
      icon: '@mipmap/ic_launcher', // Aquí puedes especificar el ícono
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Muestra la notificación
    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación
      data['title'], // Título de la notificación
      data['body'], // Cuerpo de la notificación
      platformChannelSpecifics,
      payload: 'item x', // Datos adicionales que se pueden usar al hacer clic
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Conductor",
      navigatorKey: navigatorKey,
      initialRoute: "splash",
      routes: {
        'splash': (BuildContext context) => const SplashPage(),
        'login': (BuildContext context) => const LoginPage(),
        'signup': (BuildContext context) => const SignUpPage(),
        'signup_moto': (BuildContext context) => const SignUpMotoPage(),
        'antes_iniciar': (BuildContext context) => const AntesIniciarPage(),
        'map_driver': (BuildContext context) => const MapDriverPage(),
        'verifying_identity': (BuildContext context) => const VerifyingIdentityPage(),
        'historial_viajes': (BuildContext context) => const HistorialViajesPage(),
        'recargar': (BuildContext context) => const RecargarPage(),
        'historial_recargas': (BuildContext context) => const HistorialRecargasPage(),
        'elegir_navegador': (BuildContext context) => const ElegirNavegadorPage(),
        'politicas_de_privacidad': (BuildContext context) => const PoliticasDePrivacidadPage(),
        'permisos_de_ubicacion': (BuildContext context) => const PermisosUbicacionPage(),
        'contactanos': (BuildContext context) => const ContactanosPage(),
        'compartir_aplicacion': (BuildContext context) => const CompartirAplicacionpage(),
        'select_type_user': (BuildContext context) => const SelectTypeUserPage(),
        'profile': (BuildContext context) => const ProfilePage(),
        'forgot_password': (BuildContext context) => const ForgotPage(),
        'eliminar_cuenta': (BuildContext context) => const EliminarCuentaPage(),
        'take_foto_perfil': (BuildContext context) => const TakeFotoPerfil(),
        'solicitud_servicio': (BuildContext context) => const SolicitudDeServicioPage(),
        'take_photo_cedula_delantera_page': (BuildContext context) => const TakePhotoCedulaDelanteraPage(),
        'take_photo_cedula_trasera_page': (BuildContext context) => const TakePhotoCedulaTraseraPage(),
        'take_photo_tarjeta_propiedad_delantera_page': (BuildContext context) => const TakePhotoTarjetaPropiedadDelanteraPage(),
        'take_photo_tarjeta_propiedad_trasera_page': (BuildContext context) => const TakePhotoTarjetaPropiedadTraseraPage(),
        'travel_calification_page': (BuildContext context) => const TravelCalificationPage(),
        'travel_map_page': (BuildContext context) => const TravelMapPage(arguments: null,),
        'bloqueo_page': (BuildContext context) =>  PaginaDeBloqueo(),
        'info_permisos': (BuildContext context) =>  const InfoPermisosPage(),
        'email_verification_page': (BuildContext context) =>  EmailVerificationPage()
      },
      theme: ThemeData(
        scaffoldBackgroundColor: blancoCards,
        primaryColor: primary,
        // Agrega cualquier tema personalizado aquí...
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglés, sin código de país
        Locale('es', ''), // Español, sin código de país
      ],
    );
  }
}
