import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:runrally/repository/run_repository.dart';
import 'package:runrally/models/run.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:runrally/bloc/map_bloc.dart';

// Events
abstract class RunEvent {}

class StartRunEvent extends RunEvent {
  final MapController mapController;
  final LocationData currentLocation;

  StartRunEvent(this.mapController, this.currentLocation);
}

class StopRunEvent extends RunEvent {}

class UpdateRouteEvent extends RunEvent {
  final LocationData locationData;
  final MapController mapController;

  UpdateRouteEvent(this.locationData, this.mapController);
}

class UpdateDistanceEvent extends RunEvent {
  final double distance;

  UpdateDistanceEvent(this.distance);
}

class SaveRunEvent extends RunEvent {
  final RunFinishedState runFinishedState;

  SaveRunEvent(this.runFinishedState);
}

// States
abstract class RunState {}

class RunNotStartedState extends RunState {}

class RunInProgressState extends RunState {
  final List<LatLng> routePoints;
  final Duration duration;
  final double distance;
  late final Marker marker;
  final int score;

  RunInProgressState(this.routePoints, this.duration, this.distance, this.marker, this.score);
}

class RunFinishedState extends RunState {
  final List<LatLng> routePoints;
  final Duration duration;
  final double distance;
  final int score;

  RunFinishedState(this.routePoints, this.duration, this.distance, this.score);
}

// BLoC
class RunBloc extends Bloc<RunEvent, RunState> {
  Timer? locationTimer;
  List<LatLng> routePoints = [];
  DateTime? startTime;
  double distance = 0.0;
  int score = 0;
  final RunRepository runRepository;
  final MapBloc mapBloc;

  RunBloc({required this.runRepository, required this.mapBloc}) : super(RunNotStartedState()) {
    on<StartRunEvent>((event, emit) async {
      routePoints.clear();
      startTime = DateTime.now();
      locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        Location().getLocation().then((locationData) {
          add(UpdateRouteEvent(locationData, event.mapController));
        });
      });
      Marker marker = await mapBloc.generateNearbyMarker(event.mapController, event.currentLocation);
      emit(RunInProgressState(routePoints, Duration.zero, 0.0, marker, score));
    });

    on<StopRunEvent>((event, emit) {
      locationTimer?.cancel();
      RunFinishedState runFinishedState = RunFinishedState(routePoints, DateTime.now().difference(startTime!), distance, score);
      emit(runFinishedState);
      add(SaveRunEvent(runFinishedState));
    });

    on<UpdateRouteEvent>((event, emit) async {
      if (state is RunInProgressState) {
        RunInProgressState currentState = state as RunInProgressState;

        // Calculate the distance between the user's current location and the marker's location
        double distanceToMarker = calculateDistance(event.locationData, currentState.marker.point);

        // If the distance is less than or equal to 10 meters
        if (distanceToMarker <= 10) {
          // Remove the marker
          currentState.marker = Marker(
            point: const LatLng(0, 0),
            child: Container(),
          );

          // Increment the user's score
          score++;

          // Generate a new marker
          Marker newMarker = await mapBloc.generateNearbyMarker(event.mapController, event.locationData);

          // Update the state with the new marker
          emit(RunInProgressState(
            currentState.routePoints,
            DateTime.now().difference(startTime!),
            distance,
            newMarker,
            score
          ));
        } else {
          // If the distance is more than 10 meters, just update the state as before
          emit(RunInProgressState(
            currentState.routePoints,
            DateTime.now().difference(startTime!),
            distance,
            currentState.marker,
            score
          ));
        }
      }
    });

    on<UpdateDistanceEvent>((event, emit) {
      distance += event.distance;
      if (state is RunInProgressState) {
        RunInProgressState currentState = state as RunInProgressState;
        emit(RunInProgressState(
          currentState.routePoints,
          DateTime.now().difference(startTime!),
          distance,
          currentState.marker,
          score
        ));
      }
    });

    on<SaveRunEvent>((event, emit) {
      saveRunData(event.runFinishedState);
    });
  }

  void addRoutePoint(LatLng newPoint) {
    if (state is RunInProgressState) {
      if (routePoints.isNotEmpty) {
        distance += const Distance().distance(routePoints.last, newPoint) / 1000;
      }
      routePoints.add(newPoint);
      RunInProgressState currentState = state as RunInProgressState;
      emit(RunInProgressState(routePoints, DateTime.now().difference(startTime!), distance, currentState.marker, currentState.score));
    }
  }

  void updateDistance(double newDistance) {
    distance += newDistance;
    if (state is RunInProgressState) {
      RunInProgressState currentState = state as RunInProgressState;
      emit(RunInProgressState(
        currentState.routePoints,
        DateTime.now().difference(startTime!),
        distance,
        currentState.marker,
        score
      ));
    }
  }

  void saveRunData(RunFinishedState runFinishedState) {
    Run run = Run(
      distance: runFinishedState.distance,
      duration: runFinishedState.duration,
      routePoints: runFinishedState.routePoints,
      score: runFinishedState.score,
    );
    runRepository.saveRun(run);
  }

  double calculateDistance(LocationData loc1, LatLng loc2) {
    const Distance distance = Distance();
    final LatLng point1 = LatLng(loc1.latitude!, loc1.longitude!);

    return distance(point1, loc2);
  }

  @override
  Future<void> close() {
    locationTimer?.cancel();
    return super.close();
  }
}