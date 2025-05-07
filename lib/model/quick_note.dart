import 'package:equatable/equatable.dart';

class QuickNote extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;


  const QuickNote({
    required this.id,
    required this.content,
    required this.createdAt,
  
  });

  // Create a copy of the note with updated fields
  QuickNote copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
  
  }) {
    return QuickNote(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
     
    );
  }

  // Convert from JSON (from Supabase)
  factory QuickNote.fromJson(Map<String, dynamic> json) {
    return QuickNote(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),

    );
  }

  // Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
   
    };
  }

  @override
  List<Object?> get props => [id, content, createdAt];
}
