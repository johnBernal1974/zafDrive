
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zafiro_conductores/providers/driver_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/storage_provider.dart';
import '../../../models/driver.dart';

class TakePhotoCedulaDelanteraController {

  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late StorageProvider _storageProvider = StorageProvider();
  late MyAuthProvider _authProvider;
  late DriverProvider _driverProvider;
  XFile? pickedFile;
  File? imageFile;
  late Function refresh;

  Future? init (BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    _authProvider = MyAuthProvider();
    _driverProvider = DriverProvider();
    _storageProvider = StorageProvider();
    return null;
  }

  void guardarFotoCedulaDelantera() async {
    showSimpleProgressDialog(context, 'Cargando imagen...');
    if (pickedFile != null) {
      try {
        // Comprimir la imagen antes de subirla a Firestore
        File compressedImage = await compressImage(File(pickedFile!.path));
        // Convertir el archivo comprimido a un objeto PickedFile
        PickedFile compressedPickedFile = PickedFile(compressedImage.path);
        // Subir la imagen comprimida a Firestore
        TaskSnapshot snapshot = await _storageProvider.uploadFotosDocumentos(compressedPickedFile, _authProvider.getUser()!.uid, 'foto_cedula_delantera');
        String imageUrl = await snapshot.ref.getDownloadURL();
        // Actualizar la URL de la imagen en Firestore
        Map<String, dynamic> data = {'foto_cedula_delantera': imageUrl};
        await _driverProvider.update(data, _authProvider.getUser()!.uid);
        updateFotoCedulaDelanteraATrue();
        // Ocultar el progreso una vez que se haya cargado en Firebase
        if(context.mounted){
          closeSimpleProgressDialog(context);
        }
        verificarCedulaTrasera();
      } catch (e) {
        if (kDebugMode) {
          print('Error al cargar la imagen: $e');
        }
        if(context.mounted){
          closeSimpleProgressDialog(context);
        }
      }
    } else {
      if (kDebugMode) {
        print('No se ha seleccionado ninguna foto');
      }
      closeSimpleProgressDialog(context);
    }
  }

  void verificarCedulaTrasera(){
    _authProvider.verificarFotosCedulaTrasera(context);
  }

  void showSimpleProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Función para comprimir la imagen
  Future<File> compressImage(File imageFile) async {
    try {
      // Comprimir la imagen con una calidad específica (entre 0 y 100)
      List<int> compressedImage = (await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 80, // Calidad de compresión
      )) as List<int>;

      // Guardar la imagen comprimida en un nuevo archivo
      File compressedFile = File('${imageFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedImage);
      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error al comprimir la imagen: $e');
      }
      // En caso de error, devuelve la imagen original sin comprimir
      return imageFile;
    }
  }

  void closeSimpleProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }


  void takePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      pickedFile = image;
      refresh();
    } else {
      if (kDebugMode) {
        print('No se tomó ninguna foto');
      }
    }
  }

  void updateFotoCedulaDelanteraATrue() async {
    String userId = _authProvider.getUser()!.uid;
    // Obtener el conductor actualizado
    Driver? driver = await _driverProvider.getById(userId);
    if (driver != null) {
      bool isFotoTomada = driver.ceduladelanteraTomada;
      // Mapa de datos a actualizar
      Map<String, dynamic> data;
      if (!isFotoTomada) {
        data = {
          'Verificacion_Status': "foto_tomada",
          '25_Cedula_Delantera_foto': "tomada",
          'cedula_delantera_tomada': true,
        };
      } else {
        data = {
          'Verificacion_Status': "corregida",
          '25_Cedula_Delantera_foto': "corregida",
        };
      }
      await _driverProvider.update(data, userId);
    }
  }

}