import '../../domain/entities/participant.dart';
import '../../domain/repositories/participant_repository.dart';
import '../datasources/firestore_participant_datasource.dart';

class ParticipantRepositoryImpl implements ParticipantRepository {
  final FirestoreParticipantDatasource datasource;

  ParticipantRepositoryImpl(this.datasource);

  @override
  Stream<List<Participant>> getParticipantsByEvent(String eventId) {
    return datasource.getParticipantsByEvent(eventId);
  }

  @override
  Stream<List<Participant>> getParticipantsByUser(String userId) {
    return datasource.getParticipantsByUser(userId);
  }

  @override
  Future<void> registerToEvent({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    await datasource.registerToEvent(
      eventId: eventId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }

  @override
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    return await datasource.isUserRegistered(
      eventId: eventId,
      userId: userId,
    );
  }

  @override
  Future<void> approveParticipant(String participantId) async {
    await datasource.approveParticipant(participantId);
  }

  @override
  Future<void> rejectParticipant(String participantId) async {
    await datasource.rejectParticipant(participantId);
  }

  @override
  Future<void> checkInParticipant(String participantId) async {
    await datasource.checkInParticipant(participantId);
  }

  @override
  Future<void> cancelRegistration(String participantId) async {
    await datasource.cancelRegistration(participantId);
  }

  @override
  Future<Participant?> getParticipantByQRCode(String qrCode) async {
    return await datasource.getParticipantByQRCode(qrCode);
  }
}