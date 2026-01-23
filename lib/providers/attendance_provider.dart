import 'package:flutter/material.dart';
import '../presentation/domain/entities/attendance.dart';
import '../presentation/domain/repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository repository;

  AttendanceProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Attendance> _attendances = [];
  List<Attendance> get attendances => _attendances;

  List<Attendance> _pendingAttendances = [];
  List<Attendance> get pendingAttendances => _pendingAttendances;

  Attendance? _myAttendance;
  Attendance? get myAttendance => _myAttendance;

  List<Attendance> _myAttendances = [];
  List<Attendance> get myAttendances => _myAttendances;

  Future<bool> submitAttendance({
    required String eventId,
    required String participantId,
    required String participantName,
    required String participantEmail,
    required String photoPath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.submitAttendance(
        eventId: eventId,
        participantId: participantId,
        participantName: participantName,
        participantEmail: participantEmail,
        photoPath: photoPath,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAttendances(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await repository.getAttendancesByEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingAttendances(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingAttendances = await repository.getPendingAttendances(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkMyAttendance(String eventId, String participantId) async {
    try {
      _myAttendance =
          await repository.getParticipantAttendance(eventId, participantId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> approveAttendance(String attendanceId, String adminId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.approveAttendance(attendanceId, adminId);
      
      // Update local list
      final index =
          _pendingAttendances.indexWhere((a) => a.id == attendanceId);
      if (index != -1) {
        _pendingAttendances.removeAt(index);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectAttendance(
      String attendanceId, String adminId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.rejectAttendance(attendanceId, adminId, reason);
      
      // Update local list
      final index =
          _pendingAttendances.indexWhere((a) => a.id == attendanceId);
      if (index != -1) {
        _pendingAttendances.removeAt(index);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMyAttendances(String participantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myAttendances = await repository.getMyAttendances(participantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}