import 'package:flutter/foundation.dart';
import '../presentation/domain/repositories/participant_repository.dart';

class ParticipantProvider extends ChangeNotifier {
  final ParticipantRepository _repository;
  
  bool _isLoading = false;
  String? _error;

  ParticipantProvider(this._repository);

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get participants by event ID
  Stream getParticipantsByEvent(String eventId) {
    return _repository.getParticipantsByEvent(eventId);
  }

  // Get participants by user ID (my registrations)
  Stream getParticipantsByUser(String userId) {
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.registerToEvent(
        eventId: eventId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
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

  // Check if user already registered
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
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Approve participant (Admin)
  Future<bool> approveParticipant(String participantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.approveParticipant(participantId);

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

  // Reject participant (Admin)
  Future<bool> rejectParticipant(String participantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.rejectParticipant(participantId);

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

  // Check-in participant
  Future<bool> checkInParticipant(String participantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.checkInParticipant(participantId);

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

  // Cancel registration
  Future<bool> cancelRegistration(String participantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.cancelRegistration(participantId);

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}