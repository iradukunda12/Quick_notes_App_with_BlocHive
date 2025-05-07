import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_notes_app/bloc/home_event.dart';
import 'package:quick_notes_app/bloc/home_state.dart';
import 'package:quick_notes_app/model/quick_note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class QuickNoteBloc extends Bloc<QuickNotesEvent, HomeState> {
  final SupabaseClient _supabaseClient;
  final _uuid = const Uuid();

  // Table name in Supabase
  final String _tableName = 'Quick_notes';

  QuickNoteBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const HomeLoadingState()) {
    on<QuickNotesGetAll>(_onGetAllNotes);
    on<QuickNotesAdded>(_onAddNote);
    on<QuickNotesRemoved>(_onRemoveNote);
    on<QuickNotesUpdated>(_onUpdateNote);
  }

  Future<void> _onGetAllNotes(
      QuickNotesGetAll event, Emitter<HomeState> emit) async {
    try {
      emit(const HomeLoadingState());

      // Fetch all notes from Supabase
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      final notes =
          response.map((noteJson) => QuickNote.fromJson(noteJson)).toList();

      emit(HomeLoadedState(notes));
    } catch (e) {
      emit(HomeErrorState('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onAddNote(
      QuickNotesAdded event, Emitter<HomeState> emit) async {
    try {
      // Check if we're in a loaded state
      if (state is! HomeLoadedState) {
        await _onGetAllNotes(QuickNotesGetAll(), emit);
      }

      final currentState = state as HomeLoadedState;

      // Create a new note
      final newNote = QuickNote(
        id: _uuid.v4(),
        content: event.content,
        createdAt: DateTime.now(),
      );

      // Insert to Supabase
      await _supabaseClient.from(_tableName).insert(newNote.toJson());

      // Update state with the new note added
      final updatedNotes = [newNote, ...currentState.notes];
      emit(HomeLoadedState(updatedNotes));
    } catch (e) {
      emit(HomeErrorState('Failed to add note: ${e.toString()}'));
      print(e);
    }
  }

  Future<void> _onRemoveNote(
      QuickNotesRemoved event, Emitter<HomeState> emit) async {
    try {
      if (state is! HomeLoadedState) return;

      final currentState = state as HomeLoadedState;

      // Delete from Supabase
      await _supabaseClient.from(_tableName).delete().eq('id', event.noteId);

      // Update local state by filtering out the deleted note
      final updatedNotes =
          currentState.notes.where((note) => note.id != event.noteId).toList();

      emit(HomeLoadedState(updatedNotes));
    } catch (e) {
      emit(HomeErrorState('Failed to remove note: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNote(
      QuickNotesUpdated event, Emitter<HomeState> emit) async {
    try {
      if (state is! HomeLoadedState) return;

      final currentState = state as HomeLoadedState;

      // Find the note to update
      final noteToUpdate =
          currentState.notes.firstWhere((note) => note.id == event.noteId);

      // Create updated note with new content
      final updatedNote = noteToUpdate.copyWith(
        content: event.content,
      );

      // Update in Supabase
      await _supabaseClient
          .from(_tableName)
          .update(updatedNote.toJson())
          .eq('id', updatedNote.id);

      // Update local state
      final updatedNotes = currentState.notes.map((note) {
        return note.id == updatedNote.id ? updatedNote : note;
      }).toList();

      emit(HomeLoadedState(updatedNotes));
    } catch (e) {
      emit(HomeErrorState('Failed to update note: ${e.toString()}'));
    }
  }
}
