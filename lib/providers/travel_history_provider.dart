

import 'package:cloud_firestore/cloud_firestore.dart';

import '../src/models/travelHistory.dart';

class TravelHistoryProvider{

  late CollectionReference _ref;
  TravelHistory? travelHistory;

  TravelHistoryProvider (){
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String> create(TravelHistory travelHistory) async {
    String errorMessage;

    try {
      String id = _ref.doc().id;
      travelHistory.id = id;
      // Verificar si travelHistory no es nulo antes de llamar a toJson()
      await _ref.doc(travelHistory.id).set(travelHistory.toJson());
      return id;
    } on FirebaseFirestore catch (error) {
      errorMessage = error.hashCode as String;
    }

    return Future.error(errorMessage);
  }


  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if(document.exists){
      TravelHistory? travelHistory= TravelHistory.fromJson(document.data() as Map<String, dynamic>);
      return travelHistory;
    }
    else{
      return null;
    }

  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id){
    return _ref.doc(id).delete();
  }

  Future<List<TravelHistory>> getByIdClient(String idDriver) async {
    QuerySnapshot querySnapshot = await _ref.where('idDriver', isEqualTo: idDriver).orderBy('finalViaje', descending: true).get();
    List<Map<String, dynamic>> allData = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      // Verificar si doc.data() no es nulo antes de agregarlo a la lista
      if (doc.data() != null) {
        allData.add(doc.data() as Map<String, dynamic>);
      }
    }

    List<TravelHistory> travelHistoryList = [];

    for (Map<String, dynamic> data in allData) {
      travelHistoryList.add(TravelHistory.fromJson(data));
    }

    return travelHistoryList;
  }
}