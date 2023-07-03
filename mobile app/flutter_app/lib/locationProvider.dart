import 'dart:math' show cos, sqrt, asin;

import 'package:location/location.dart';

import 'location.dart';

class LocationProvider {
  static LatLng _lastUserLocation;

  /// Returns the last location of the used device
  static LatLng get getLastLocation => _lastUserLocation;
  static Location location = new Location();

  static bool _serviceEnabled = false;
  static PermissionStatus _permissionGranted;
  // Allows getLocation to call itself on timeout
  static Future<LocationData> getLocation() async {
    if(!_serviceEnabled) {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          print("Location Service disabled");
          return null;
        }
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Location Permission denied");
        return null;
      }
    }

    print("getting location ...");
    return await location.getLocation();
  }






  // Returns distance in KM
  static double calculateDistanceToLastLocation(LatLng loc1, LatLng loc2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((loc2.latitude - loc1.latitude) * p) / 2 +
        c(loc1.latitude * p) * c(loc2.latitude * p) * (1 - c((loc2.longitude - loc1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
