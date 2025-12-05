// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../bloc/location_bloc.dart';
// import 'history_screen.dart';
// import 'map_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LocationBloc, LocationState>(
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: state.isDarkMode
//               ? const Color(0xFF0A0F1F)
//               : const Color(0xFFF0F4FF),
//           appBar: AppBar(
//             centerTitle: true,
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             title: Text(
//               'Live Route',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//                 letterSpacing: 1,
//                 color: state.isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: Icon(
//                   state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                   size: 26,
//                 ),
//                 onPressed: () =>
//                     context.read<LocationBloc>().add(ToggleTheme()),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.history,
//                   size: 26,
//                   color: state.isDarkMode ? Colors.white : Colors.black,
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HistoryScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: _buildBody(context, state),
//         );
//       },
//     );
//   }

//   Widget _buildBody(BuildContext context, LocationState state) {
//     if (state.errorType == LocationErrorType.internetUnavailable) {
//       return _errorWidget(
//         context,
//         title: "No Internet",
//         icon: Icons.wifi_off,
//         message: "Please check your internet connection and try again.",
//       );
//     }

//     if (state.errorType == LocationErrorType.permissionDenied) {
//       return _errorWidget(
//         context,
//         title: "Permission Denied",
//         customImage: 'assets/images/location_error.png',
//         message:
//             "Location permission denied. Enable permissions and restart the app.",
//       );
//     }

//     if (state.isLoading || state.currentLocation == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final loc = state.currentLocation!;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.blueAccent.withOpacity(0.15),
//             ),
//             child: const Icon(
//               Icons.location_searching_rounded,
//               size: 70,
//               color: Colors.blueAccent,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             "Live  Location",
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).primaryColorDark,
//             ),
//           ),
//           const SizedBox(height: 25),

//           // Glass-like info card
//           _glassContainer(
//             child: Column(
//               children: [
//                 Text(
//                   loc.address ?? "Fetching address...",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _latLngBox("Latitude", loc.latitude.toStringAsFixed(4)),
//                     _latLngBox("Longitude", loc.longitude.toStringAsFixed(4)),
//                   ],
//                 ),
//                 const SizedBox(height: 18),
//                 Text(
//                   "Last Updated: ${DateFormat('hh:mm:ss a').format(loc.timestamp)}",
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Gradient button implemented using decorated Container
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const MapScreen()),
//               );
//             },
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF6D83F2), Color(0xFF3AA6F5)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.12),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: const Center(
//                 child: Text(
//                   "View on Map",
//                   style: TextStyle(
//                     fontSize: 18,
//                     letterSpacing: 0.5,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),
//           // VISITED LOCATIONS SECTION
//           if (state.visitedLocations.isNotEmpty) ...[
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Visited Locations",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).textTheme.bodyLarge?.color,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 120,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: state.visitedLocations.length,
//                 itemBuilder: (context, index) {
//                   // Show reverse order (newest first)
//                   final loc =
//                       state.visitedLocations[state.visitedLocations.length -
//                           1 -
//                           index];
//                   return Container(
//                     width: 200,
//                     margin: const EdgeInsets.only(right: 12),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.grey.withOpacity(0.2)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on,
//                               size: 16,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 DateFormat(
//                                   'MMM dd, hh:mm a',
//                                 ).format(loc.timestamp),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Theme.of(context).primaryColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           loc.address ??
//                               "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontSize: 12, height: 1.3),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _glassContainer({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           colors: [
//             Colors.white.withOpacity(0.12),
//             Colors.white.withOpacity(0.06),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.18)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.12),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _latLngBox(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
//           decoration: BoxDecoration(
//             color: Colors.blueAccent.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Text(value, style: const TextStyle(fontSize: 16)),
//         ),
//       ],
//     );
//   }

//   Widget _errorWidget(
//     BuildContext context, {
//     required String title,
//     String? customImage,
//     IconData? icon,
//     required String message,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon != null)
//               Icon(icon, size: 100, color: Colors.redAccent)
//             else if (customImage != null)
//               Image.asset(customImage, height: 180)
//             else
//               const SizedBox.shrink(),
//             const SizedBox(height: 25),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.redAccent.shade400,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
        final isDark = state.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0A0F1F)
              : const Color(0xFFF3F6FF),

          // ------------------ APP BAR ------------------
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              "Live Route",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () =>
                    context.read<LocationBloc>().add(ToggleTheme()),
              ),
              IconButton(
                icon: Icon(
                  Icons.history,
                  color: isDark ? Colors.white : Colors.black87,
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

          // ------------------ BODY ------------------
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LocationState state) {
    final isDark = state.isDarkMode;

    // INTERNET ERROR
    if (state.errorType == LocationErrorType.internetUnavailable) {
      return _errorWidget(
        context,
        title: "No Internet",
        icon: Icons.wifi_off_rounded,
        message:
            "Your device is offline. Please turn on internet and try again.",
      );
    }

    // PERMISSION ERROR
    if (state.errorType == LocationErrorType.permissionDenied) {
      return _errorWidget(
        context,
        customImage: 'assets/images/location_error.png',
        title: "Permission Denied",
        message: "Enable GPS/location permissions and restart the app.",
      );
    }

    // LOADING
    if (state.isLoading || state.currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final loc = state.currentLocation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ------------------ LOCATION ICON ------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade300.withOpacity(.2),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              size: 70,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Live Location",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 25),

          // ------------------ GLASS CARD ------------------
          _glassContainer(
            isDark: isDark,
            child: Column(
              children: [
                Text(
                  loc.address ?? "Fetching Address...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _latLngBox(
                      isDark: isDark,
                      label: "Latitude",
                      value: loc.latitude.toStringAsFixed(4),
                    ),
                    _latLngBox(
                      isDark: isDark,
                      label: "Longitude",
                      value: loc.longitude.toStringAsFixed(4),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  "Updated at: ${DateFormat('hh:mm:ss a').format(loc.timestamp)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ------------------ MAP BUTTON ------------------
          GestureDetector(
            onTap: () {
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
                  colors: [Color(0xFF5E77FF), Color(0xFF1BCDFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "View on Map",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          // ------------------ VISITED LOCATIONS ------------------
          if (state.visitedLocations.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Visited Locations",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // HORIZONTAL SCROLL CARDS
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.visitedLocations.length,
                itemBuilder: (context, index) {
                  final visited = state.visitedLocations.reversed
                      .toList()[index];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(14),
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(.05),
                                Colors.white.withOpacity(.03),
                              ]
                            : [
                                Colors.white.withOpacity(.7),
                                Colors.white.withOpacity(.5),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(.1)
                            : Colors.black.withOpacity(.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: isDark
                                  ? Colors.lightBlueAccent
                                  : Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'MMM dd, hh:mm a',
                                ).format(visited.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.lightBlueAccent
                                      : Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          visited.address ??
                              "${visited.latitude.toStringAsFixed(4)}, ${visited.longitude.toStringAsFixed(4)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------ GLASS CARD ------------------
  Widget _glassContainer({required bool isDark, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.white.withOpacity(.08), Colors.white.withOpacity(.04)]
              : [Colors.white.withOpacity(.6), Colors.white.withOpacity(.35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.1)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ------------------ COORDINATE BOX ------------------
  Widget _latLngBox({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.blueAccent.withOpacity(.15)
                : Colors.blueAccent.withOpacity(.1),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ ERROR WIDGET ------------------
  Widget _errorWidget(
    BuildContext context, {
    required String title,
    String? customImage,
    IconData? icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 100, color: Colors.redAccent),
          if (customImage != null) Image.asset(customImage, height: 160),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
