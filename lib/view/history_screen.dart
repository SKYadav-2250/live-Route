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
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        // Modern Deep Space / Clean Light Gradient
        final bgGradient = isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: bgGradient),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, isDark, state.trips.isNotEmpty),

                  if (state.trips.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context, isDark),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final reversedIndex = state.trips.length - 1 - index;
                          final trip = state.trips[reversedIndex];
                          return _ModernTripCard(trip: trip, isDark: isDark);
                        }, childCount: state.trips.length),
                      ),
                    ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    bool isDark,
    bool hasHistory,
  ) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      pinned: true,
      expandedHeight: 60,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Your Journeys",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        if (hasHistory)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: Colors.red[400]),
              onPressed: () => _confirmDelete(context),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.map_outlined,
              size: 60,
              color: isDark
                  ? Colors.blueGrey
                  : Colors.blueAccent.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No History Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    // ... (Your existing delete logic) ...
    context.read<LocationBloc>().add(ClearHistory());
  }
}

// --------------------------------------------------------------------------
//  MODERN TRIP CARD WIDGET
// --------------------------------------------------------------------------
class _ModernTripCard extends StatelessWidget {
  final TripModel trip;
  final bool isDark;

  const _ModernTripCard({required this.trip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final duration = trip.endTime != null
        ? trip.endTime!.difference(trip.startTime)
        : Duration.zero;

    final durationString = duration.inHours > 0
        ? "${duration.inHours}h ${duration.inMinutes % 60}m"
        : "${duration.inMinutes} min";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapScreen(trip: trip)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF283244) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle background decoration
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.directions_outlined,
                  size: 150,
                  color: isDark
                      ? Colors.white.withOpacity(0.02)
                      : Colors.blueAccent.withOpacity(0.03),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("EEEE, MMM d").format(trip.startTime),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat("yyyy").format(trip.startTime),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3B82F6).withOpacity(0.2)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: Colors.blue[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                durationString,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.blue[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    IntrinsicHeight(
                      child: Row(
                        children: [
                          // TIMELINE VISUAL
                          Column(
                            children: [
                              _buildTimelineNode(isStart: true),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blueAccent,
                                        isDark
                                            ? Colors.purpleAccent
                                            : Colors.deepPurpleAccent,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              _buildTimelineNode(isStart: false),
                            ],
                          ),

                          const SizedBox(width: 15),

                          // ADDRESS DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // START
                                _buildAddressBlock(
                                  label: "Start",
                                  time: trip.startTime,
                                  address:
                                      trip.locations.firstOrNull?.address ??
                                      "Unknown",
                                  isDark: isDark,
                                ),

                                const Spacer(), // Pushes Start up and End down
                                const SizedBox(height: 20),

                                // END
                                _buildAddressBlock(
                                  label: "Destination",
                                  time: trip.endTime,
                                  address:
                                      trip.locations.lastOrNull?.address ??
                                      "Current Location",
                                  isDark: isDark,
                                  isDest: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom "View Map" Stripe
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineNode({required bool isStart}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isStart
            ? Colors.blueAccent
            : (isDark ? Colors.purpleAccent : Colors.deepPurpleAccent),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF283244) : Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isStart ? Colors.blueAccent : Colors.purple).withOpacity(
              0.4,
            ),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBlock({
    required String label,
    DateTime? time,
    required String address,
    required bool isDark,
    bool isDest = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              time != null ? DateFormat("hh:mm a").format(time) : "Now",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDest
                    ? (isDark ? Colors.purpleAccent : Colors.deepPurpleAccent)
                    : Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "•  $label",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
