import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/firestore_attendance_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirestoreAttendanceDatasource datasource;

  AttendanceRepositoryImpl({required this.datasource});

  @override
  Future<String> submitAttendance({
    required String eventId,
    required String participantId,
    required String participantName,
    required String participantEmail,
    required String photoPath,
  }) async {
    return await datasource.submitAttendance(
      eventId: eventId,
      participantId: participantId,
      participantName: participantName,
      participantEmail: participantEmail,
      photoPath: photoPath,
    );
  }

  @override
  Future<List<Attendance>> getAttendancesByEvent(String eventId) async {
    return await datasource.getAttendancesByEvent(eventId);
  }

  @override
  Future<List<Attendance>> getPendingAttendances(String eventId) async {
    return await datasource.getPendingAttendances(eventId);
  }

  @override
  Future<Attendance?> getParticipantAttendance(
      String eventId, String participantId) async {
    return await datasource.getParticipantAttendance(eventId, participantId);
  }

  @override
  Future<void> approveAttendance(String attendanceId, String adminId) async {
    await datasource.approveAttendance(attendanceId, adminId);
  }

  @override
  Future<void> rejectAttendance(
      String attendanceId, String adminId, String reason) async {
    await datasource.rejectAttendance(attendanceId, adminId, reason);
  }

  @override
  Future<List<Attendance>> getMyAttendances(String participantId) async {
    return await datasource.getMyAttendances(participantId);
  }
}