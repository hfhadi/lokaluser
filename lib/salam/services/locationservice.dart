import 'dart:async';

import 'package:location/location.dart';
import 'package:lokaluser/salam/services/userlocation.dart';

class LocationService {
  UserLocation? _currentLocation;

  var location = Location();
  final StreamController<UserLocation> _locationController = StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation!;
  }
}
