
class Attendance {
  final String id;
  final String eventId;
  final String participantId;
  final String participantName;
  final String participantEmail;
  final DateTime checkInTime;
  final String? photoUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  Attendance({
    required this.id,
    required this.eventId,
    required this.participantId,
    required this.participantName,
    required this.participantEmail,
    required this.checkInTime,
    this.photoUrl,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  Attendance copyWith({
    String? id,
    String? eventId,
    String? participantId,
    String? participantName,
    String? participantEmail,
    DateTime? checkInTime,
    String? photoUrl,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return Attendance(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantEmail: participantEmail ?? this.participantEmail,
      checkInTime: checkInTime ?? this.checkInTime,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}