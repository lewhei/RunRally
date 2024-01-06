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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  late MapController mapController;
  LocationData? currentLocation;
  late StreamSubscription<LocationData> locationSubscription;
  double zoomLevel = 16.0;

  late RunBloc runBloc;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    runBloc = RunBloc();
    _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<MapBloc, MapState>(
      builder: (context, mapState) {
        return Scaffold(
          body: FlutterMap(
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
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: ColorPalette.lightGreen,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  runBloc.add(StartRunEvent());
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
                backgroundColor: currentLocation != null ? ColorPalette.accentBlue : Colors.grey,
                child: currentLocation != null ? const Icon(Icons.my_location) : const Icon(Icons.location_searching),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initLocation() {
    locationSubscription = Location().onLocationChanged.listen(
          (LocationData locationData) {
        setState(() {
          currentLocation = locationData;
          runBloc.updateRoute(locationData);
        });
      },
    );
  }

  void _focusOnUserLocation() {
    if (currentLocation != null) {
      mapController.move(
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoomLevel,
      );
    }
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
