import 'package:geolocator/geolocator.dart';

class LocationService {
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  Stream<Position> getLocationStream() {
    return _geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    ));
  }
}
