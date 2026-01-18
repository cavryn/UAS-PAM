import '../../domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.name,
    required super.description,
    required super.date,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> json, String id) {
    return EventModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'date': date,
    };
  }
}