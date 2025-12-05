import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/location_bloc.dart';
import '../model/location_model.dart';
import '../model/trip_model.dart';
import 'history_screen.dart';

class MapScreen extends StatefulWidget {
  final TripModel? trip;
  final LocationModel? historyLocation;

  const MapScreen({super.key, this.trip, this.historyLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    // End trip when leaving the map screen (if it was a live trip)
    if (widget.trip == null && widget.historyLocation == null) {
      context.read<LocationBloc>().add(EndTrip());
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _loadTripData();
    } else if (widget.historyLocation != null) {
      _addHistoryMarker();
    }
  }

  void _loadTripData() {
    if (widget.trip == null || widget.trip!.locations.isEmpty) return;

    List<LatLng> points = [];
    Set<Marker> markers = {};

    for (var loc in widget.trip!.locations) {
      points.add(LatLng(loc.latitude, loc.longitude));

      // Add Markers based on type
      if (loc.type == LocationType.start) {
        markers.add(_createMarker(loc, BitmapDescriptor.hueRed, "Start"));
      } else if (loc.type == LocationType.end) {
        markers.add(_createMarker(loc, BitmapDescriptor.hueGreen, "End"));
      } else if (loc.type == LocationType.stop) {
        markers.add(_createMarker(loc, BitmapDescriptor.hueViolet, "Stop"));
      }
    }

    // Add Polyline
    _polylines.add(
      Polyline(
        polylineId: PolylineId(widget.trip!.id),
        points: points,
        color: Colors.blue,
        width: 5,
      ),
    );

    setState(() {
      _markers = markers;
    });
  }

  void _addHistoryMarker() {
    final loc = widget.historyLocation!;
    _markers.add(
      Marker(
        markerId: MarkerId('history_${loc.timestamp}'),
        position: LatLng(loc.latitude, loc.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Visited Location',
          snippet: DateFormat('dd MMM yyyy \at hh:mm a').format(loc.timestamp),
        ),
      ),
    );
  }

  Marker _createMarker(LocationModel loc, double hue, String title) {
    return Marker(
      markerId: MarkerId('${loc.latitude}_${loc.longitude}_${loc.timestamp}'),
      position: LatLng(loc.latitude, loc.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: title,
        snippet: DateFormat('dd MMM yyyy \at hh:mm a').format(loc.timestamp),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (widget.trip != null && widget.trip!.locations.isNotEmpty) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (widget.trip == null || widget.trip!.locations.isEmpty) return;

    double minLat = widget.trip!.locations.first.latitude;
    double maxLat = widget.trip!.locations.first.latitude;
    double minLng = widget.trip!.locations.first.longitude;
    double maxLng = widget.trip!.locations.first.longitude;

    for (var loc in widget.trip!.locations) {
      if (loc.latitude < minLat) minLat = loc.latitude;
      if (loc.latitude > maxLat) maxLat = loc.latitude;
      if (loc.longitude < minLng) minLng = loc.longitude;
      if (loc.longitude > maxLng) maxLng = loc.longitude;
    }

    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Route'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              Set<Marker> displayMarkers = Set.from(_markers);
              Set<Polyline> displayPolylines = Set.from(_polylines);

              if (widget.trip == null &&
                  widget.historyLocation == null &&
                  state.currentLocation != null) {
                // Live Mode
                if (state.currentTrip != null) {
                  List<LatLng> currentPoints = state.currentTrip!.locations
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList();

                  // Update polyline for live tracking
                  // Note: Ideally we shouldn't recreate Polyline every frame if possible, but for now it's fine
                  displayPolylines.add(
                    Polyline(
                      polylineId: const PolylineId('current_trip'),
                      points: currentPoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  );

                  // Add Start Marker
                  if (state.currentTrip!.locations.isNotEmpty) {
                    final startLoc = state.currentTrip!.locations.first;
                    displayMarkers.add(
                      Marker(
                        markerId: const MarkerId('start_marker'),
                        position: LatLng(startLoc.latitude, startLoc.longitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: InfoWindow(
                          title: "Start",
                          snippet: DateFormat(
                            'hh:mm a',
                          ).format(startLoc.timestamp),
                        ),
                      ),
                    );
                  }
                }
              }

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target:
                      widget.trip != null && widget.trip!.locations.isNotEmpty
                      ? LatLng(
                          widget.trip!.locations.first.latitude,
                          widget.trip!.locations.first.longitude,
                        )
                      : (widget.historyLocation != null
                            ? LatLng(
                                widget.historyLocation!.latitude,
                                widget.historyLocation!.longitude,
                              )
                            : (state.currentLocation != null
                                  ? LatLng(
                                      state.currentLocation!.latitude,
                                      state.currentLocation!.longitude,
                                    )
                                  : const LatLng(0, 0))),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: _currentMapType,
                markers: displayMarkers,
                polylines: displayPolylines,
              );
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "mapTypeBtn",
              onPressed: _toggleMapType,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                Icons.layers,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
