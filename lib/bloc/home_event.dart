import 'package:equatable/equatable.dart';

abstract class QuickNotesEvent extends Equatable {
  const QuickNotesEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch all notes
class QuickNotesGetAll extends QuickNotesEvent {
  const QuickNotesGetAll();
}

// Event to add a new note
class QuickNotesAdded extends QuickNotesEvent {
  final String content;

  const QuickNotesAdded(this.content);

  @override
  List<Object?> get props => [content];
}

// Event to remove a note
class QuickNotesRemoved extends QuickNotesEvent {
  final String noteId;

  const QuickNotesRemoved({required this.noteId});

  @override
  List<Object?> get props => [noteId];
}

// Event to update a note
class QuickNotesUpdated extends QuickNotesEvent {
  final String noteId;
  final String content;

  const QuickNotesUpdated({
    required this.noteId,
    required this.content,
  });

  @override
  List<Object?> get props => [noteId, content];
}
