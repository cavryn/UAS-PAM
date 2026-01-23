import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<String> submitAttendance({
    required String eventId,
    required String participantId,
    required String participantName,
    required String participantEmail,
    required String photoPath,
  });

  Future<List<Attendance>> getAttendancesByEvent(String eventId);
  
  Future<List<Attendance>> getPendingAttendances(String eventId);
  
  Future<Attendance?> getParticipantAttendance(String eventId, String participantId);
  
  Future<void> approveAttendance(String attendanceId, String adminId);
  
  Future<void> rejectAttendance(String attendanceId, String adminId, String reason);
  
  Future<List<Attendance>> getMyAttendances(String participantId);
}