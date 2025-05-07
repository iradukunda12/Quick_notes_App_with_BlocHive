import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_notes_app/bloc/home_bloc.dart';
import 'package:quick_notes_app/bloc/home_event.dart';
import 'package:quick_notes_app/bloc/home_state.dart';
import 'package:quick_notes_app/widget/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final textController = TextEditingController();
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load notes when screen initializes
    context.read<QuickNoteBloc>().add(QuickNotesGetAll());
  }

  @override
  void dispose() {
    textController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "Quick Notes",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search....",
                hintStyle: const TextStyle(
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // BLoC Consumer for notes display
          Expanded(
            child: BlocConsumer<QuickNoteBloc, HomeState>(
              listener: (context, state) {
                if (state is HomeErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is HomeLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is HomeLoadedState) {
                  final notes = state.notes;

                  // Filter notes based on search query
                  final filteredNotes = searchQuery.isEmpty
                      ? notes
                      : notes
                          .where((note) =>
                              note.content.toLowerCase().contains(searchQuery))
                          .toList();

                  if (filteredNotes.isEmpty) {
                    return const Center(
                      child: Text("No notes found"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteCard(
                        note: note,
                        onDelete: () {
                          context.read<QuickNoteBloc>().add(
                                QuickNotesRemoved(noteId: note.id),
                              );
                        },
                        onEdit: (updatedContent) {
                          context.read<QuickNoteBloc>().add(
                                QuickNotesUpdated(
                                  noteId: note.id,
                                  content: updatedContent,
                                ),
                              );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 53.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "Enter your note here",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  final noteContent = textController.text.trim();
                  if (noteContent.isNotEmpty) {
                    // Add a new note using the bloc
                    context.read<QuickNoteBloc>().add(
                          QuickNotesAdded(noteContent),
                        );
                    // Clear the text field
                    textController.clear();
                  }
                  print(noteContent);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
