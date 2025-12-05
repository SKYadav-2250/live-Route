part of 'location_bloc.dart';

enum LocationErrorType { none, permissionDenied, internetUnavailable }

class LocationState extends Equatable {
  final LocationModel? currentLocation;
  final List<TripModel> trips;
  final List<LocationModel> visitedLocations;
  final TripModel? currentTrip;
  final bool isLoading;
  final LocationErrorType errorType;
  final bool isDarkMode;

  const LocationState({
    this.currentLocation,
    this.trips = const [],
    this.visitedLocations = const [],
    this.currentTrip,
    this.isLoading = false,
    this.errorType = LocationErrorType.none,
    this.isDarkMode = false,
  });

  LocationState copyWith({
    LocationModel? currentLocation,
    List<TripModel>? trips,
    List<LocationModel>? visitedLocations,
    TripModel? currentTrip,
    bool clearCurrentTrip = false,
    bool? isLoading,
    LocationErrorType? errorType,
    bool? isDarkMode,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      trips: trips ?? this.trips,
      visitedLocations: visitedLocations ?? this.visitedLocations,
      currentTrip: clearCurrentTrip ? null : (currentTrip ?? this.currentTrip),
      isLoading: isLoading ?? this.isLoading,
      errorType: errorType ?? this.errorType,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    trips,
    visitedLocations,
    currentTrip,
    isLoading,
    errorType,
    isDarkMode,
  ];
}
