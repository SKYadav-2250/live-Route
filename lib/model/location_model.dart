enum LocationType { start, end, stop, path }

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;
  final LocationType type;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
    this.type = LocationType.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] != null
          ? LocationType.values.firstWhere(
              (e) => e.toString() == json['type'],
              orElse: () => LocationType.path,
            )
          : LocationType.path,
    );
  }

  @override
  String toString() {
    return 'Lat: $latitude, Lng: $longitude, Time: $timestamp, Type: $type';
  }
}
