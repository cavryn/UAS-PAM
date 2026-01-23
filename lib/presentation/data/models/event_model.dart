import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.name,
    required super.description,
    required super.date,
    required super.location,
    required super.quota,
    required super.createdBy,
    required super.status,
    required super.createdAt,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> json, String id) {
    return EventModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      quota: json['quota'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      status: json['status'] ?? 'published',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'quota': quota,
      'createdBy': createdBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}