import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class MapEvent {}

class SomeMapEvent extends MapEvent {}

// States
abstract class MapState {}

class InitialMapState extends MapState {}

class MapLoadedState extends MapState {}

// BLoC
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(InitialMapState());

  @override
  MapState get initialState => InitialMapState();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is SomeMapEvent) {
      // Handle map events and update state accordingly
      yield MapLoadedState();
    }
  }
}
