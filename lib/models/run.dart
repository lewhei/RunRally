import 'package:latlong2/latlong.dart';

class Run {
  final double distance;
  final Duration duration;
  final List<LatLng> routePoints;
  final int score;

  Run({
    required this.distance,
    required this.duration,
    required this.routePoints,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'duration': duration.inSeconds,
      'routePoints': routePoints.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList(),
      'score': score,
    };
  }
}
