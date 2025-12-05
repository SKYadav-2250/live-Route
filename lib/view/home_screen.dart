import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/location_bloc.dart';
import 'history_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        // Background Gradient
        final bgGradient = isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFFF3F6FF), Color(0xFFE2E8F0)],
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
                  // 1. App Bar
                  _buildSliverAppBar(context, isDark),

                  // 2. Body Content Logic
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorType ==
                      LocationErrorType.internetUnavailable)
                    SliverFillRemaining(
                      child: _buildError(
                        Icons.wifi_off_rounded,
                        "No Internet",
                        "Check your connection.",
                      ),
                    )
                  else if (state.errorType ==
                      LocationErrorType.permissionDenied)
                    SliverFillRemaining(
                      child: _buildError(
                        Icons.location_disabled,
                        "Permission Denied",
                        "Please enable location services.",
                      ),
                    )
                  else if (state.currentLocation != null) ...[
                    // 3. Live Location Card Area
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            // Pass dynamic to avoid type errors
                            _buildLiveLocationCard(
                              state.currentLocation,
                              isDark,
                            ),
                            const SizedBox(height: 25),
                            _buildMapButton(context),
                            const SizedBox(height: 35),

                            // "Recent History" Header
                            Row(
                              children: [
                                Icon(
                                  Icons.timeline,
                                  color: isDark
                                      ? Colors.blue[300]
                                      : Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Recent History",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),

                    // 4. Vertical Timeline List
                    if (state.visitedLocations.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Text(
                              "No locations visited yet.",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          // Show newest first
                          final actualIndex =
                              state.visitedLocations.length - 1 - index;
                          final loc = state.visitedLocations[actualIndex];

                          final isFirst = index == 0;
                          final isLast =
                              index == state.visitedLocations.length - 1;

                          return _buildTimelineItem(
                            loc,
                            isDark,
                            isFirst,
                            isLast,
                          );
                        }, childCount: state.visitedLocations.length),
                      ),

                    const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------- HELPER WIDGETS -------------------------

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      centerTitle: true,
      title: Text(
        "Live Route",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          color: isDark ? Colors.amber : Colors.grey[800],
          // Ensure ToggleTheme is imported from your bloc file
          onPressed: () => context.read<LocationBloc>().add(ToggleTheme()),
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded),
          color: isDark ? Colors.white : Colors.black87,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }

  // Using 'dynamic' for loc to avoid import errors if LocationData isn't visible
  Widget _buildLiveLocationCard(dynamic loc, bool isDark) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // The Glass Card
        Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(0.9)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.white,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                loc.address ?? "Fetching Address...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCoordItem(
                      "LAT",
                      loc.latitude.toStringAsFixed(4),
                      isDark,
                    ),
                    Container(height: 30, width: 1, color: Colors.grey[300]),
                    _buildCoordItem(
                      "LNG",
                      loc.longitude.toStringAsFixed(4),
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Updated: ${DateFormat('hh:mm:ss a').format(loc.timestamp)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // The Floating Pulsing Icon
        Positioned(
          top: 0,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 10 + (_pulseController.value * 15),
                      spreadRadius: _pulseController.value * 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoordItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blue[200] : Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      ),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "View on Map",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    dynamic loc,
    bool isDark,
    bool isFirst,
    bool isLast,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: isFirst
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.3),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                ),
              ),
              Container(
                width: 2,
                height: 60, // Minimum height of connection line
                color: isLast
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 15),

          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapScreen(historyLocation: loc),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? Colors.blue[300] : Colors.blue[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('hh:mm a').format(loc.timestamp),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue[100] : Colors.blue[900],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd').format(loc.timestamp),
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.address ??
                          "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(IconData icon, String title, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.red[300]),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
