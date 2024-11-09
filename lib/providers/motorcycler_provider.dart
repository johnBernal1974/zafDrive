

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../src/models/motorcycler.dart';

class MotorcyclerProvider{

  late CollectionReference _ref;

  MotorcyclerProvider (){
    _ref = FirebaseFirestore.instance.collection('Motorcyclers');
  }

  Future<void> create(Motorcycler motorcycler){
    String errorMessage;

    try{
      return _ref.doc(motorcycler.id).set(motorcycler.toJson());
    }on FirebaseFirestore catch(error){
      errorMessage = error.hashCode as String;
    }

    return Future.error(errorMessage);
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Motorcycler?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if(document.exists){
      Motorcycler motorcycler= Motorcycler.fromJson(document.data() as Map<String, dynamic>);
      return motorcycler;
    }
    else{
      return null;
    }

  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<String?> getVerificationStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _ref.doc(user.uid).get();
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          return userData['Verificacion_Status'];
        }
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Error al obtener el estado de verificación: $error');
      }
      return null;
    }
  }

  Future<String> verificarFotoPerfil() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Drivers').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoPerfil = userData['29_Foto_perfil'] ?? "false";
          return fotoPerfil;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al verificar la foto de perfil: $error');
      }
      return "false";
    }
  }

  Future<String> verificarFotoCedulaDelantera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Drivers').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoCedulaDelantera = userData['25_Cedula_Delantera_foto'] ?? "false";
          return fotoCedulaDelantera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al verificar la foto de la cedula delantera: $error');
      }
      return "false";
    }
  }

  Future<String> verificarFotoCedulaTrasera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Drivers').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fotoCedulaTrasera = userData['26_Cedula_Trasera_foto'] ?? "false";
          return fotoCedulaTrasera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al verificar la foto de cedula trasera: $error');
      }
      return "false";
    }
  }

  Future<String> verificarFotoTarjetaPropiedadDelantera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Drivers').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fototarjetaPropiedadDelantera = userData['27_Tarjeta_Propiedad_Delantera_foto'] ?? "false";
          return fototarjetaPropiedadDelantera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al verificar la foto tarjeta propiedad delantera: $error');
      }
      return "false";
    }
  }

  Future<String> verificarFotoTarjetaPropiedadTrasera() async {
    try {
      // Obtener la referencia del usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtener el estado de la foto de perfil del usuario actual desde la base de datos
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Drivers').doc(user.uid).get();
        if (snapshot.exists) {
          // Verificar si la foto de perfil está verificada o no
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String fototarjetaPropiedadTrasera = userData['28_Tarjeta_Propiedad_Trasera_foto'] ?? "false";
          return fototarjetaPropiedadTrasera;
        } else {
          // Si no se encuentra el documento del usuario, la foto de perfil no está verificada
          return "false";
        }
      } else {
        // Si no hay usuario autenticado, retornar false
        return "false";
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al verificar la foto tarjeta propiedad trasera: $error');
      }
      return "false";
    }
  }


}