# Live Route – Real-Time Location Tracking App

Live Route is a Flutter application that tracks user movement in real time, detects trips automatically, and visualizes routes on Google Maps. It also stores visited locations permanently and displays them in a simple, modern UI.

## ⭐ Features

- **Live GPS Tracking** – continuously tracks and updates location
- **Trip Detection** – automatically detects Start, End, Stops
- **GPS Noise Filtering** – ignores small movements (<10 meters)
- **Route Visualization**
  - Blue polyline for movement path
  - Green start marker
  - Red end marker
- **Visited Locations** – stores and shows unique locations permanently
- **History Page** – view past trips with timestamps

## 🧩 APIs & Packages Used (Simple Explanation)

### 1. Google Maps Flutter
Used to display:
- The map
- Markers (start, stop, end)
- Polylines for route paths

This provides the full visual experience of the app.

### 2. Geolocator
Used to get:
- Live location
- Latitude & longitude
- Movement updates

### 3. Geocoding
- Converts coordinates → human-readable addresses.
- Used for history cards like: "Model Town, Ludhiana"

### 4. Flutter BLoC (State Management)
The core logic is handled using BLoC, which helps:
- Process continuous location updates
- Detect trips
- Filter GPS noise
- Update UI without lag

### 5. Shared Preferences
Used to store visited locations and trips permanently so data remains even after closing the app.

## 👨‍💻 How My Experience Helped

My experience with Flutter and BLoC allowed me to:
- Handle continuous GPS updates efficiently
- Separate UI and logic → better performance
- Implement trip detection logic cleanly
- Build a smooth, modern interface without UI lag
- Manage map updates and state changes correctly

Using BLoC ensured that even with heavy background processing (GPS, stops, trip logic), the UI stays fast and stable.

## 🛠 Built With

Flutter • Dart • BLoC • Google Maps API