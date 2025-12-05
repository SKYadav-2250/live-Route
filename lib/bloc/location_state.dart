part of 'location_bloc.dart';

enum LocationErrorType { none, permissionDenied, internetUnavailable }

class LocationState extends Equatable {
  final LocationModel? currentLocation;
  final List<TripModel> trips;
  final TripModel? currentTrip;
  final bool isLoading;
  final LocationErrorType errorType;
  final bool isDarkMode;

  const LocationState({
    this.currentLocation,
    this.trips = const [],
    this.currentTrip,
    this.isLoading = false,
    this.errorType = LocationErrorType.none,
    this.isDarkMode = false,
  });

  LocationState copyWith({
    LocationModel? currentLocation,
    List<TripModel>? trips,
    TripModel? currentTrip,
    bool? isLoading,
    LocationErrorType? errorType,
    bool? isDarkMode,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      trips: trips ?? this.trips,
      currentTrip: currentTrip ?? this.currentTrip,
      isLoading: isLoading ?? this.isLoading,
      errorType: errorType ?? this.errorType,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    trips,
    currentTrip,
    isLoading,
    errorType,
    isDarkMode,
  ];
}
