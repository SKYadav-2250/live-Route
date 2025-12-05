import 'location_model.dart';

class TripModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<LocationModel> locations;

  TripModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.locations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'locations': locations.map((e) => e.toJson()).toList(),
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      locations: (json['locations'] as List)
          .map((e) => LocationModel.fromJson(e))
          .toList(),
    );
  }

  TripModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<LocationModel>? locations,
  }) {
    return TripModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locations: locations ?? this.locations,
    );
  }
}
