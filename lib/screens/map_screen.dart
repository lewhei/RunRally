import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:runrally/bloc/map_bloc.dart';
import 'package:runrally/bloc/run_bloc.dart';
import 'package:runrally/color_palette.dart';
import 'package:runrally/repository/run_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  late MapController mapController;
  LocationData? currentLocation;
  late StreamSubscription<LocationData> locationSubscription;
  double zoomLevel = 16.0;

  late RunBloc runBloc;
  late MapBloc mapBloc;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    runBloc = RunBloc(runRepository: RunRepository(), mapBloc: mapBloc);
    mapBloc = MapBloc();
    _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocProvider<RunBloc>.value(
        value: runBloc,
        child: Stack(
          children: [
            BlocBuilder<MapBloc, MapState>(
              builder: (context, mapState) {
                return FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      currentLocation?.latitude ?? 49.6338,
                      currentLocation?.longitude ?? 8.3443,
                    ),
                    initialZoom: zoomLevel,
                  ),
                  mapController: mapController,
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: runBloc.routePoints,
                          strokeWidth: 4.0,
                          color: ColorPalette.darkGreen,
                        ),
                      ]
                    ),
                    CurrentLocationLayer(
                      style: const LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          color: ColorPalette.lightGreen,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<RunBloc, RunState>(
              builder: (context, state) {
                if (state is RunInProgressState) {
                  return const RunInfoBanner();
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (runBloc.state is RunNotStartedState ||
                  runBloc.state is RunFinishedState) {
                runBloc.add(StartRunEvent(mapController, currentLocation!));
              } else if (runBloc.state is RunInProgressState) {
                runBloc.add(StopRunEvent());
              }
            },
            backgroundColor: runBloc.state is RunInProgressState
                ? ColorPalette.accentAmber
                : ColorPalette.darkGreen,
            child: Icon(runBloc.state is RunInProgressState
                ? Icons.stop
                : Icons.play_arrow),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: currentLocation != null ? _focusOnUserLocation : null,
            backgroundColor:
            currentLocation != null ? ColorPalette.accentBlue : Colors.grey,
            child: currentLocation != null
                ? const Icon(Icons.my_location)
                : const Icon(Icons.location_searching),
          ),
        ],
      ),
    );
  }

  void _initLocation() {
    Location location = Location();
    location.changeSettings(interval: 5000);
    List<LocationData> locationBuffer = [];
    int bufferSize = 5;

    locationSubscription = Location().onLocationChanged.listen(
          (LocationData newLocation) {
        locationBuffer.add(newLocation);
        if (locationBuffer.length > bufferSize) {
          locationBuffer.removeAt(0);
        }

        // Calculate the average latitude and longitude
        double avgLatitude = locationBuffer.map((loc) => loc.latitude!).reduce((a, b) => a + b) / locationBuffer.length;
        double avgLongitude = locationBuffer.map((loc) => loc.longitude!).reduce((a, b) => a + b) / locationBuffer.length;

        LocationData avgLocation = LocationData.fromMap({
          'latitude': avgLatitude,
          'longitude': avgLongitude,
        });

        if (currentLocation != null) {
          double distance = calculateDistance(currentLocation!, avgLocation);
          if (distance > 10 && distance < 1000) {
            runBloc.updateDistance(distance / 1000);
          }
        }

        setState(() {
          currentLocation = avgLocation;
        });

        LatLng newPoint = LatLng(avgLocation.latitude!, avgLocation.longitude!);
        runBloc.addRoutePoint(newPoint);
      },
    );
  }

  double calculateDistance(LocationData loc1, LocationData loc2) {
    const Distance distance = Distance();
    final LatLng point1 = LatLng(loc1.latitude!, loc1.longitude!);
    final LatLng point2 = LatLng(loc2.latitude!, loc2.longitude!);

    return distance(point1, point2);
  }

  void _focusOnUserLocation() {
    if (currentLocation != null) {
      mapController.move(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoomLevel,
      );
    }
  }

  void _startRun() {
    runBloc.add(StartRunEvent(mapController, currentLocation!));
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    runBloc.close();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class RunInfoBanner extends StatelessWidget {
  const RunInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RunBloc, RunState>(
      builder: (context, state) {
        if (state is RunInProgressState) {
          RunInProgressState runState = state;
          Duration duration = runState.duration;
          double distance = runState.distance;
          int score = runState.score;
          String distanceDisplay;
          if (distance < 1) {
            // Display the distance in meters if it's less than 1 kilometer
            distanceDisplay = '${(distance * 1000).round()} m';
          } else {
            // Otherwise, display the distance in kilometers
            distanceDisplay = '${distance.toStringAsFixed(2)} km';
          }

          // Calculate minutes and seconds
          String minutes = duration.inMinutes.toString().padLeft(2, '0');
          String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

          return Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Duration: $minutes:$seconds min'),
                Text('Distance: $distanceDisplay'),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
