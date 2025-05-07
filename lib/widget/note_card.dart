import 'package:flutter/material.dart';
import 'package:quick_notes_app/model/quick_note.dart';

class NoteCard extends StatefulWidget {
  final QuickNote note;
  final VoidCallback onDelete;
  final Function(String) onEdit;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late TextEditingController _editController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note content or edit field
            _isEditing
                ? TextField(
                    controller: _editController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.note.content,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(widget.note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    // Edit/Save button
                    IconButton(
                      icon: Icon(_isEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        if (_isEditing) {
                          // Save changes
                          final newContent = _editController.text.trim();
                          if (newContent.isNotEmpty) {
                            widget.onEdit(newContent);
                          }
                        } else {
                          // Start editing
                          _editController.text = widget.note.content;
                        }
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text(
                                'Are you sure you want to delete this note?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
