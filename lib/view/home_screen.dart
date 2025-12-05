import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/location_bloc.dart';
import 'history_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state.isDarkMode
              ? const Color(0xFF0A0F1F)
              : const Color(0xFFF0F4FF),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Live Route',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1,
                color: state.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: 26,
                ),
                onPressed: () =>
                    context.read<LocationBloc>().add(ToggleTheme()),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  size: 26,
                  color: state.isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LocationState state) {
    if (state.errorType == LocationErrorType.internetUnavailable) {
      return _errorWidget(
        context,
        title: "No Internet",
        icon: Icons.wifi_off,
        message: "Please check your internet connection and try again.",
      );
    }

    if (state.errorType == LocationErrorType.permissionDenied) {
      return _errorWidget(
        context,
        title: "Permission Denied",
        customImage: 'assets/images/location_error.png',
        message:
            "Location permission denied. Enable permissions and restart the app.",
      );
    }

    if (state.isLoading || state.currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final loc = state.currentLocation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.location_searching_rounded,
              size: 70,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Live Location",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 25),

          // Glass-like info card
          _glassContainer(
            child: Column(
              children: [
                Text(
                  loc.address ?? "Fetching address...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _latLngBox("Latitude", loc.latitude.toStringAsFixed(4)),
                    _latLngBox("Longitude", loc.longitude.toStringAsFixed(4)),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  "Last Updated: ${DateFormat('hh:mm:ss a').format(loc.timestamp)}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Gradient button implemented using decorated Container
          GestureDetector(
            onTap: () {
              context.read<LocationBloc>().add(StartTrip());
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D83F2), Color(0xFF3AA6F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "View on Map",
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _latLngBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _errorWidget(
    BuildContext context, {
    required String title,
    String? customImage,
    IconData? icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 100, color: Colors.redAccent)
            else if (customImage != null)
              Image.asset(customImage, height: 180)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 25),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
