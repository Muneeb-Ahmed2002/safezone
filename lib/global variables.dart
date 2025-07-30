import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

String? userName;
String? name = 'User 01';
String Token = "";

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