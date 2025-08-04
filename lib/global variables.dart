import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';

String? userName;
String? name = 'User 01';
String Token = "";
late double latitude;
late double longitude;

bool userExist = false;
Future<void> checkIfDocExist(user) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(user);
  final docSnapshot = await docRef.get();
  if(docSnapshot.exists){
    name = await docSnapshot.data()?['Name'];
    userExist = true;
  }
  else{userExist = false;}
}

Future<bool> checkLocationLastUpdated() async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(userName);
  final docSnapshot = await docRef.get();
  if(docSnapshot.exists){
    final lastLocationUpdate = await (docSnapshot.data()?['time'] as Timestamp).toDate();
    print(lastLocationUpdate);
    if(lastLocationUpdate == null){
      return false;
    }
    else{
      final interval = DateTime.now().difference(lastLocationUpdate);
      print(interval.inMinutes);
      if(interval.inMinutes<=30){
        return true;
      }
      else{
        return false;
      }
    }


  }
  else{return false;}
}

Future<void> sendLocationToFirebase(double latitude,double longitude) async {

  print('$latitude, $longitude');

  List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

  String stAdd = '${placemarks.reversed.last.street!}, ${placemarks.reversed.last.locality!}, ${placemarks.reversed.last.country!}';
  print('Current Location $stAdd');
  checkLocationLastUpdated().then((lastTime) async {
    if(lastTime){
      print('No Updates made to firebase');
    }
    else{
      await FirebaseFirestore.instance.collection('Users').doc(userName).update(
          {
            'longitude': longitude,
            'latitude': latitude,
            'address': stAdd,
            'deviceToken' : Token,
            'time': DateTime.now(),
          });
    }
  });

}