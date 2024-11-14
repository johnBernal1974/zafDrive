

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zafiro_conductores/src/models/client.dart';
import 'package:zafiro_conductores/src/models/client.dart';

class ClientProvider{

  late CollectionReference _ref;
  Client? client;

  ClientProvider (){
    _ref = FirebaseFirestore.instance.collection('Clients');
  }

  Future<void> create(){
    String errorMessage;
    try{
      return _ref.doc(client?.id).set(client?.toJson());
    }on FirebaseFirestore catch(error){
      errorMessage = error.hashCode as String;
    }
    return Future.error(errorMessage);
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<Client?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if(document.exists){
      Client? client= Client.fromJson(document.data() as Map<String, dynamic>);
      return client;
    }
    else{
      return null;
    }
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }
}