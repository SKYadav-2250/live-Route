import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../model/location_model.dart';
import '../model/trip_model.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/storage_service.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();
  final StorageService _storageService = StorageService();
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _stopTimer;
  DateTime? _lastMoveTime;

  LocationBloc() : super(const LocationState()) {
    on<LocationStarted>(_onStarted);
    on<LocationUpdated>(_onLocationUpdated);
    on<ToggleTheme>(_onToggleTheme);
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ClearHistory>(_onClearHistory);
    on<StartTrip>(_onStartTrip);
    on<EndTrip>(_onEndTrip);
    on<StopDetected>(_onStopDetected);
  }

  Future<void> _onStarted(
    LocationStarted event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Load Trips & Visited Locations
    final trips = await _storageService.getTrips();
    final visited = await _storageService.getVisitedLocations();
    emit(state.copyWith(trips: trips, visitedLocations: visited));

    // Check Connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(
        state.copyWith(
          errorType: LocationErrorType.internetUnavailable,
          isLoading: false,
        ),
      );
      _monitorConnectivity();
      return;
    }

    _monitorConnectivity();

    // Check Permissions
    LocationPermission permission = await _locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          errorType: LocationErrorType.permissionDenied,
          isLoading: false,
        ),
      );
      return;
    }

    // Start Tracking (but NOT recording a trip yet)
    emit(state.copyWith(errorType: LocationErrorType.none, isLoading: true));

    try {
      final position = await _locationService.getCurrentLocation();
      add(LocationUpdated(position));

      _positionStreamSubscription = _locationService.getPositionStream().listen(
        (position) {
          add(LocationUpdated(position));
        },
      );
    } catch (e) {
      // Handle errors
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) async {
    final String? address = await _geocodingService.getAddressFromLatLng(
      event.position.latitude,
      event.position.longitude,
    );

    // Determine Location Type
    LocationType type = LocationType.path;
    if (state.currentTrip?.locations.isEmpty ?? true) {
      type = LocationType.start;
    }

    final newLocation = LocationModel(
      latitude: event.position.latitude,
      longitude: event.position.longitude,
      address: address,
      timestamp: DateTime.now(),
      type: type,
    );

    // Update Current Location
    emit(state.copyWith(currentLocation: newLocation, isLoading: false));

    // VISITED LOCATIONS LOGIC
    // Check if distinct from last visited location (> 100m)
    List<LocationModel> visited = List.from(state.visitedLocations);
    bool addToVisited = false;
    if (visited.isEmpty) {
      addToVisited = true;
    } else {
      final lastVisited = visited.last;
      final distance = Geolocator.distanceBetween(
        lastVisited.latitude,
        lastVisited.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );
      if (distance > 100) {
        addToVisited = true;
      }
    }

    if (addToVisited) {
      visited.add(newLocation);
      emit(state.copyWith(visitedLocations: visited));
      await _storageService.saveVisitedLocations(visited);
    }

    // Trip Logic
    if (state.currentTrip != null) {
      List<LocationModel> updatedLocations = List.from(
        state.currentTrip!.locations,
      );

      // Distance Filter (10 meters)
      bool shouldAdd = false;
      if (updatedLocations.isEmpty) {
        shouldAdd = true;
      } else {
        final lastLoc = updatedLocations.last;
        final distance = Geolocator.distanceBetween(
          lastLoc.latitude,
          lastLoc.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );
        if (distance >= 10) {
          shouldAdd = true;
        }
      }

      if (shouldAdd) {
        updatedLocations.add(newLocation);
        _lastMoveTime = DateTime.now();

        // Reset Stop Timer
        _stopTimer?.cancel();
        _stopTimer = Timer(const Duration(minutes: 3), () {
          add(StopDetected());
        });
      } else {
        // If we haven't moved > 10m, check if it's been > 3 mins since last move
        if (_lastMoveTime != null &&
            DateTime.now().difference(_lastMoveTime!).inMinutes >= 3) {
          add(StopDetected());
        }
      }

      final updatedTrip = state.currentTrip!.copyWith(
        locations: updatedLocations,
      );
      emit(state.copyWith(currentTrip: updatedTrip));

      // INCREMENTAL PERSISTENCE: Save trip state on every update to prevent data loss
      await _storageService.saveTrips([updatedTrip, ...state.trips]);
    }
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<LocationState> emit,
  ) async {
    if (state.currentTrip != null) return; // Already in a trip

    final newTrip = TripModel(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      locations: state.currentLocation != null
          ? [
              state.currentLocation!.copyWith(
                type: LocationType.start,
                timestamp: DateTime.now(),
              ),
            ]
          : [],
    );
    emit(state.copyWith(currentTrip: newTrip));

    // Start periodic timer for stop detection
    _stopTimer?.cancel();
    _stopTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_lastMoveTime != null &&
          DateTime.now().difference(_lastMoveTime!).inMinutes >= 3) {
        add(StopDetected());
      }
    });

    // Save initial state
    await _storageService.saveTrips([newTrip, ...state.trips]);
  }

  Future<void> _onEndTrip(EndTrip event, Emitter<LocationState> emit) async {
    if (state.currentTrip != null) {
      List<LocationModel> locations = List.from(state.currentTrip!.locations);

      // Fetch Fresh Location for accuracy
      try {
        final position = await _locationService.getCurrentLocation();
        final String? address = await _geocodingService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        locations.add(
          LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
            timestamp: DateTime.now(),
            type: LocationType.end,
          ),
        );
        // emit(state.copyWith(currentTrip: state.currentTrip!.copyWith(locations: locations)));
      } catch (e) {
        // Fallback to last known location if fetch fails
        if (locations.isNotEmpty) {
          var last = locations.last;
          locations.add(
            last.copyWith(type: LocationType.end, timestamp: DateTime.now()),
          );
        }
      }

      final completedTrip = state.currentTrip!.copyWith(
        endTime: DateTime.now(),
        locations: locations,
      );

      // Update state with new trip at the top
      final newTrips = List<TripModel>.from(state.trips)
        ..insert(0, completedTrip);
      emit(state.copyWith(trips: newTrips, clearCurrentTrip: true));

      // Save finalized list
      await _storageService.saveTrips(newTrips);
    } else {
      emit(state.copyWith(clearCurrentTrip: true));
    }
    _stopTimer?.cancel();
    _lastMoveTime = null;
  }

  Future<void> _onStopDetected(
    StopDetected event,
    Emitter<LocationState> emit,
  ) async {
    if (state.currentTrip != null && state.currentTrip!.locations.isNotEmpty) {
      final lastLocation = state.currentTrip!.locations.last;

      // Avoid adding duplicate stops
      if (lastLocation.type != LocationType.stop) {
        final stopLocation = lastLocation.copyWith(
          type: LocationType.stop,
          timestamp: DateTime.now(),
        );

        List<LocationModel> updatedLocations = List.from(
          state.currentTrip!.locations,
        );
        updatedLocations.add(stopLocation);

        final updatedTrip = state.currentTrip!.copyWith(
          locations: updatedLocations,
        );
        emit(state.copyWith(currentTrip: updatedTrip));

        // Reset timer
        _stopTimer?.cancel();
        _lastMoveTime = DateTime.now();
      }
    }
  }

  void _onToggleTheme(ToggleTheme event, Emitter<LocationState> emit) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<LocationState> emit,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(state.copyWith(errorType: LocationErrorType.internetUnavailable));
    } else {
      if (state.errorType == LocationErrorType.internetUnavailable) {
        add(LocationStarted());
      }
    }
  }

  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<LocationState> emit,
  ) async {
    await _storageService.clearHistory();
    emit(state.copyWith(trips: []));
  }

  void _monitorConnectivity() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      add(CheckConnectivity());
    });
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _stopTimer?.cancel();
    return super.close();
  }
}

extension LocationModelCopy on LocationModel {
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
    LocationType? type,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
