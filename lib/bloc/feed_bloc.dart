import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class FeedEvent {}

class SomeFeedEvent extends FeedEvent {}

// States
abstract class FeedState {}

class InitialFeedState extends FeedState {}

class FeedLoadedState extends FeedState {}

// BLoC
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(InitialFeedState());

  @override
  FeedState get initialState => InitialFeedState();

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is SomeFeedEvent) {
      // Handle feed events and update state accordingly
      yield FeedLoadedState();
    }
  }
}
