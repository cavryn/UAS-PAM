import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class FirestoreAttendanceDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert image file to Base64 string
  Future<String> _convertImageToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> submitAttendance({
    required String eventId,
    required String participantId,
    required String participantName,
    required String participantEmail,
    required String photoPath,
  }) async {
    try {
      // Convert foto ke Base64 string (GRATIS - tanpa Storage)
      final photoBase64 = await _convertImageToBase64(photoPath);

      // Buat attendance document dengan foto Base64
      final attendanceData = {
        'eventId': eventId,
        'participantId': participantId,
        'participantName': participantName,
        'participantEmail': participantEmail,
        'checkInTime': Timestamp.now(),
        'photoBase64': photoBase64, // Simpan sebagai Base64
        'status': 'pending',
        'createdAt': Timestamp.now(),
      };

      final docRef =
          await _firestore.collection('attendances').add(attendanceData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit attendance: $e');
    }
  }

  Future<List<AttendanceModel>> getAttendancesByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendances')
          .where('eventId', isEqualTo: eventId)
          .orderBy('checkInTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendances: $e');
    }
  }

  Future<List<AttendanceModel>> getPendingAttendances(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendances')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'pending')
          .orderBy('checkInTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending attendances: $e');
    }
  }

  Future<AttendanceModel?> getParticipantAttendance(
      String eventId, String participantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendances')
          .where('eventId', isEqualTo: eventId)
          .where('participantId', isEqualTo: participantId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return AttendanceModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get participant attendance: $e');
    }
  }

  Future<void> approveAttendance(String attendanceId, String adminId) async {
    try {
      await _firestore.collection('attendances').doc(attendanceId).update({
        'status': 'approved',
        'approvedAt': Timestamp.now(),
        'approvedBy': adminId,
      });
    } catch (e) {
      throw Exception('Failed to approve attendance: $e');
    }
  }

  Future<void> rejectAttendance(
      String attendanceId, String adminId, String reason) async {
    try {
      await _firestore.collection('attendances').doc(attendanceId).update({
        'status': 'rejected',
        'approvedAt': Timestamp.now(),
        'approvedBy': adminId,
        'adminNotes': reason,
      });
    } catch (e) {
      throw Exception('Failed to reject attendance: $e');
    }
  }

  Future<List<AttendanceModel>> getMyAttendances(String participantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendances')
          .where('participantId', isEqualTo: participantId)
          .orderBy('checkInTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get my attendances: $e');
    }
  }
}