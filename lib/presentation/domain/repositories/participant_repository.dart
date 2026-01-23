import '../entities/participant.dart';

abstract class ParticipantRepository {
  Stream<List<Participant>> getParticipantsByEvent(String eventId);
  Stream<List<Participant>> getParticipantsByUser(String userId);
  Stream<List<Participant>> getPendingParticipants();
  
  Future<void> registerToEvent({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  });
  
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  });
  
  Future<void> approveParticipant(String participantId);
  Future<void> rejectParticipant(String participantId);
  Future<void> checkInParticipant(String participantId);
  Future<void> checkInParticipantByQR(String qrCode);
  Future<void> cancelRegistration(String participantId);
  Future<Participant?> getParticipantByQRCode(String qrCode);
}