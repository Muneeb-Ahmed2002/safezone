import 'package:flutter/material.dart';
import 'package:location/location.dart';

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
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location permission denied.");
        return;
      }
    }

    print("Location permission granted.");
  }

  Future<LocationData?> getLocationData() async {
    try {
      await location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: 1000);
      _locationData = await location.getLocation();
      print('Location Captured');
      return _locationData;
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}