import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:runrally/color_palette.dart';


// Events
abstract class MapEvent {}

class GenerateRandomMarkerEvent extends MapEvent {
  final MapController mapController;
  final LocationData currentLocation;

  GenerateRandomMarkerEvent(this.mapController, this.currentLocation);
}

// States
abstract class MapState {}

class MapInitial extends MapState {}

class MarkerGenerated extends MapState {
  final Marker marker;

  MarkerGenerated(this.marker);
}

// Bloc
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial());

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is GenerateRandomMarkerEvent) {
      // Generate the random marker
      Marker marker = await generateNearbyMarker(event.mapController, event.currentLocation);
      yield MarkerGenerated(marker);
    }
  }

  Future<Marker> generateNearbyMarker(MapController mapController, LocationData currentLocation) async {
    // Define the radius of the Earth
    const double earthRadius = 6371e3;

    // Convert the distance to radians
    double distance = 250 / earthRadius;

    // Generate random bearing
    double bearing = Random().nextDouble() * 2 * pi;

    // Convert the user's latitude and longitude to radians
    double userLatRadians = currentLocation.latitude! * (pi / 180);
    double userLonRadians = currentLocation.longitude! * (pi / 180);

    // Calculate the new latitude and longitude
    double newLatRadians = asin(sin(userLatRadians) * cos(distance) + cos(userLatRadians) * sin(distance) * cos(bearing));
    double newLonRadians = userLonRadians + atan2(sin(bearing) * sin(distance) * cos(userLatRadians), cos(distance) - sin(userLatRadians) * sin(newLatRadians));

    // Convert the new latitude and longitude back to degrees
    double newLat = newLatRadians * (180 / pi);
    double newLon = newLonRadians * (180 / pi);

    // Create a marker at the new coordinates
    var marker = Marker(
      width: 0.0,
      height: 0.0,
      point: LatLng(newLat, newLon),
      child: const Icon(Icons.star, color: ColorPalette.accentAmber),
    );

    // Get nearest road using Overpass API
    var overpassUrl = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=[out:json];way(around:75,$newLat,$newLon);out geom;'
    );

    var response = await get(overpassUrl);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var elements = data['elements'] as List;

      if (elements.isNotEmpty) {
        var nearestRoad = elements[0];
        var geometry = nearestRoad['geometry'] as List;
        var firstPoint = geometry[0];

        // Update the marker's coordinates to nearest road
        marker = Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(firstPoint['lat'], firstPoint['lon']),
          child: const Icon(Icons.star, color: ColorPalette.accentAmber),
        );
      }
    }

    return marker;
  }
}