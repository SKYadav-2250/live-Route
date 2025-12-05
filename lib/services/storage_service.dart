import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/trip_model.dart';

class StorageService {
  static const String _historyKey = 'trip_history';

  Future<void> saveTrips(List<TripModel> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      trips.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_historyKey, encodedData);
  }

  Future<List<TripModel>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_historyKey);

    if (encodedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((e) => TripModel.fromJson(e)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
