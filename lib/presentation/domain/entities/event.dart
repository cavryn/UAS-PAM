class Event {
  final String id;
  final String name;
  final String description;
  final String date;
  final String location;
  final int quota;
  final String createdBy;
  final String status;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.quota,
    required this.createdBy,
    required this.status,
    required this.createdAt,
  });

  bool get isDraft => status == 'draft';
  bool get isPublished => status == 'published';
  bool get isOngoing => status == 'ongoing';
  bool get isCompleted => status == 'completed';
}