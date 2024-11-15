

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';


class GeofireProvider{

  late CollectionReference _ref;
  late GeoFlutterFire _geo;

  GeofireProvider(){
    _ref = FirebaseFirestore.instance.collection('Locations');
    _geo = GeoFlutterFire();
  }

  Stream<DocumentSnapshot> getLocationByIdStream(String id){
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<void> create(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({'status': 'driver_available', 'position': myLocation.data});
  }

  Future<void> createMotorcycler(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({'status': 'motorcycler_available', 'position': myLocation.data});
  }

  Future<void> createWorking(String id, double lat, double lng) {
    GeoFirePoint myLocation = _geo.point(latitude: lat, longitude: lng);
    return _ref.doc(id).set({'status': 'driver_working', 'position': myLocation.data});
  }


  Future<void> delete(String id){
    return _ref.doc(id).delete();
  }
}