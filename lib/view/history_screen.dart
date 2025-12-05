import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/location_bloc.dart';
import '../model/trip_model.dart';
import 'map_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? const Color(0xFF0A0F1F)
          : const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          "Trip History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear History",
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 80),
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state.trips.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _tripCard(context, state.trips[index]);
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Clear History?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            "This action will permanently delete all your trip records."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              context.read<LocationBloc>().add(ClearHistory());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------
  // EMPTY STATE
  //---------------------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 90,
            color: Colors.blueAccent.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          Text(
            "No Trips Recorded",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your trip history will appear here.",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          )
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------
  // TRIP CARD
  //---------------------------------------------------------------------------
  Widget _tripCard(BuildContext context, TripModel trip) {
    final startLocation = trip.locations.firstOrNull;
    final endLocation = trip.locations.lastOrNull;
    final duration = trip.endTime != null
        ? trip.endTime!.difference(trip.startTime)
        : Duration.zero;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapScreen(trip: trip)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--------------------------------------------------------------------
            // HEADER ROW
            //--------------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("dd MMM yyyy").format(trip.startTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${duration.inMinutes} min",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //--------------------------------------------------------------------
            // START LOCATION
            //--------------------------------------------------------------------
            _locationRow(
              icon: Icons.radio_button_checked,
              color: Colors.redAccent,
              address: startLocation?.address ?? "Unknown Start",
              time: DateFormat("hh:mm a").format(trip.startTime),
            ),

            // Dotted Line
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Container(
                height: 20,
                width: 2,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            //--------------------------------------------------------------------
            // END LOCATION
            //--------------------------------------------------------------------
            _locationRow(
              icon: Icons.location_on,
              color: Colors.green,
              address: endLocation?.address ?? "Unknown End",
              time: trip.endTime != null
                  ? DateFormat("hh:mm a").format(trip.endTime!)
                  : "Ongoing",
            ),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------
  // LOCATION ROW
  //---------------------------------------------------------------------------
  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String address,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
