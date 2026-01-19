import 'package:flutter/foundation.dart';
import '../presentation/domain/repositories/participant_repository.dart';
import '../presentation/domain/entities/participant.dart';

class ParticipantProvider with ChangeNotifier {
  final ParticipantRepository _repository;

  ParticipantProvider(this._repository);

  // State management
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Get pending participants
  Stream<List<Participant>> getPendingParticipants() {
    return _repository.getPendingParticipants();
  }

  // Get participants by event
  Stream<List<Participant>> getParticipantsByEvent(String eventId) {
    return _repository.getParticipantsByEvent(eventId);
  }

  // Get participants by user
  Stream<List<Participant>> getParticipantsByUser(String userId) {
    return _repository.getParticipantsByUser(userId);
  }

  // Register to event
  Future<bool> registerToEvent({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.registerToEvent(
        eventId: eventId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      print('Error registering to event: $e');
      return false;
    }
  }

  // Check if user registered
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    try {
      return await _repository.isUserRegistered(
        eventId: eventId,
        userId: userId,
      );
    } catch (e) {
      print('Error checking registration: $e');
      return false;
    }
  }

  // Approve participant
  Future<bool> approveParticipant(String participantId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.approveParticipant(participantId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menyetujui peserta: ${e.toString()}');
      _setLoading(false);
      print('Error approving participant: $e');
      return false;
    }
  }

  // Reject participant
  Future<bool> rejectParticipant(String participantId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.rejectParticipant(participantId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal menolak peserta: ${e.toString()}');
      _setLoading(false);
      print('Error rejecting participant: $e');
      return false;
    }
  }

  // Check-in participant
  Future<bool> checkInParticipant(String participantId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.checkInParticipant(participantId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal check-in peserta: ${e.toString()}');
      _setLoading(false);
      print('Error checking in participant: $e');
      return false;
    }
  }

  // Cancel registration
  Future<bool> cancelRegistration(String participantId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _repository.cancelRegistration(participantId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Gagal membatalkan pendaftaran: ${e.toString()}');
      _setLoading(false);
      print('Error canceling registration: $e');
      return false;
    }
  }

  // Get participant by QR Code
  Future<Participant?> getParticipantByQRCode(String qrCode) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final participant = await _repository.getParticipantByQRCode(qrCode);
      _setLoading(false);
      return participant;
    } catch (e) {
      _setError('Gagal mencari peserta: ${e.toString()}');
      _setLoading(false);
      print('Error getting participant by QR: $e');
      return null;
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
}