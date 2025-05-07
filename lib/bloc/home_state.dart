import 'package:equatable/equatable.dart';
import 'package:quick_notes_app/model/quick_note.dart';


// Base state class
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// Initial loading state
class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

// State when notes are loaded successfully
class HomeLoadedState extends HomeState {
  final List<QuickNote> notes;

  const HomeLoadedState(this.notes);

  @override
  List<Object?> get props => [notes];
}

// State when an error occurs
class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
