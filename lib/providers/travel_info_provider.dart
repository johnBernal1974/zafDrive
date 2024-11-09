
import 'package:cloud_firestore/cloud_firestore.dart';

import '../src/models/travel_info.dart';

class TravelInfoProvider {

  late CollectionReference _ref;
  
  TravelInfoProvider() {
    _ref = FirebaseFirestore.instance.collection('TravelInfo');
  }

  Stream<DocumentSnapshot> getByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void> create(TravelInfo travelInfo){
    String errorMessage;

    try{
      return _ref.doc(travelInfo.id).set(travelInfo.toJson());
    }on FirebaseFirestore catch(error){
      errorMessage = error.hashCode as String;
    }

    return Future.error(errorMessage);
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<TravelInfo?> getById(String id) async {
    // Verificar si el ID está vacío
    if (id.isEmpty) {
      throw Exception('El ID del documento no puede estar vacío.');
    }

    DocumentSnapshot document = await _ref.doc(id).get();

    if (document.exists) {
      TravelInfo travelInfo = TravelInfo.fromJson(document.data() as Map<String, dynamic>);
      return travelInfo;
    } else {
      return null; // O lanzar una excepción si prefieres
    }
  }

  // Método para actualizar la distancia recorrida en la base de datos
  Future<void> updateDistanciaRecorrida(String id, double nuevaDistancia) async {
    try {
      await _ref.doc(id).update({'distanciaRecorrida': nuevaDistancia});
    } catch (error) {
      throw 'Error al actualizar la distancia recorrida: $error';
    }
  }

  Future<void> updateTarifa(String id, double tarifa) async {
    try {
      await _ref.doc(id).update({'tarifa': tarifa});
    } catch (error) {
      throw 'Error al actualizar la tarifa: $error';
    }
  }

}