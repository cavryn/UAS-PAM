// lib/presentation/data/models/attendance_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  AttendanceModel({
    required super.id,
    required super.eventId,
    required super.participantId,
    required super.participantName,
    required super.participantEmail,
    required super.checkInTime,
    super.photoUrl,
    required super.status,
    super.adminNotes,
    required super.createdAt,
    super.approvedAt,
    super.approvedBy,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      participantId: data['participantId'] ?? '',
      participantName: data['participantName'] ?? '',
      participantEmail: data['participantEmail'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      photoUrl: data['photoBase64'],
      status: data['status'] ?? 'pending',
      adminNotes: data['adminNotes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'participantId': participantId,
      'participantName': participantName,
      'participantEmail': participantEmail,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'photoBase64': photoUrl,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  factory AttendanceModel.fromEntity(Attendance attendance) {
    return AttendanceModel(
      id: attendance.id,
      eventId: attendance.eventId,
      participantId: attendance.participantId,
      participantName: attendance.participantName,
      participantEmail: attendance.participantEmail,
      checkInTime: attendance.checkInTime,
      photoUrl: attendance.photoUrl,
      status: attendance.status,
      adminNotes: attendance.adminNotes,
      createdAt: attendance.createdAt,
      approvedAt: attendance.approvedAt,
      approvedBy: attendance.approvedBy,
    );
  }
}