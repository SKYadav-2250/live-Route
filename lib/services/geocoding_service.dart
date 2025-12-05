import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format: Street, City, State, Postal Code
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }
}
