import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationServices{
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  requestLocationServices() async {
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = (await location.requestPermission()) as bool;
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
    }
  }
  getLocationData() async {
    await location.changeSettings(accuracy: LocationAccuracy.navigation, distanceFilter: 1000);
    _locationData = await location.getLocation();
    return _locationData;
  }
}