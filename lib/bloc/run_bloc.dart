import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

// Events
abstract class RunEvent {}

class StartRunEvent extends RunEvent {}

class StopRunEvent extends RunEvent {}

// States
abstract class RunState {}

class RunNotStartedState extends RunState {}

class RunInProgressState extends RunState {
  final List<LatLng> routePoints;

  RunInProgressState(this.routePoints);
}

class RunFinishedState extends RunState {
  final List<LatLng> routePoints;

  RunFinishedState(this.routePoints);
}

// BLoC
class RunBloc extends Bloc<RunEvent, RunState> {
  RunBloc() : super(RunNotStartedState());

  List<LatLng> routePoints = [];

  @override
  Stream<RunState> mapEventToState(RunEvent event) async* {
    if (event is StartRunEvent) {
      routePoints.clear();
      yield RunInProgressState(routePoints);
    } else if (event is StopRunEvent) {
      yield RunFinishedState(routePoints);
    }
  }

  void updateRoute(LocationData locationData) {
    if (state is RunInProgressState) {
      routePoints.add(LatLng(locationData.latitude!, locationData.longitude!));
      add(RunInProgressState(routePoints) as RunEvent);
    }
  }
}
