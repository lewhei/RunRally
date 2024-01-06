import 'package:google_maps_flutter/google_maps_flutter.dart';

class Run {
  final DateTime startTime;
  final DateTime endTime;
  final double distance;
  final List<LatLng> routePoints;

  const Run({
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.routePoints,
  });
}
