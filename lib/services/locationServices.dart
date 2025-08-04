import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../global variables.dart';

class LocationServices{
  final location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> requestLocationServices() async {
    _serviceEnabled = await location.serviceEnabled();
    print('Checking Location Services');
    if (!_serviceEnabled) {
      print('Location Services not enabled asking for permissions');
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("Location service is not enabled.");
      }
    }
    else{
      _permissionGranted = await location.hasPermission();
      if(_permissionGranted == PermissionStatus.deniedForever){
        _permissionGranted = await location.requestPermission();
      }
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print("Location permission denied.");
        }
      }
      getLocationData();
      print("Location permission granted.");
    }

  }

  getLocationData() async {
    try {
      await location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1000);
      _locationData = await location.getLocation();
      print('Location Captured');
      if (_locationData != null &&
          _locationData.latitude != null &&
          _locationData.longitude != null) {
        print('Location Found $_locationData');
        latitude = _locationData.latitude!;
        longitude = _locationData.longitude!;
        if(userExist){
          sendLocationToFirebase(_locationData.latitude!, _locationData.longitude!);
        }
        print('In Device Memory: $latitude, $longitude, $userExist');
        print(DateTime.now());
      }
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}