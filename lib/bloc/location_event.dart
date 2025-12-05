part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LocationStarted extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;
  const LocationUpdated(this.position);

  @override
  List<Object> get props => [position];
}

class ToggleTheme extends LocationEvent {}

class CheckConnectivity extends LocationEvent {}

class ClearHistory extends LocationEvent {}

class StopDetected extends LocationEvent {}
