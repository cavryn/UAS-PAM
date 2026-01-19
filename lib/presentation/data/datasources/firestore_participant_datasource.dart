import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant_model.dart';
import 'dart:math';

class FirestoreParticipantDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get participants by event ID
  Stream<List<ParticipantModel>> getParticipantsByEvent(String eventId) {
    return _firestore
        .collection('participants')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ParticipantModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get participants by user ID (my events)
  Stream<List<ParticipantModel>> getParticipantsByUser(String userId) {
    return _firestore
        .collection('participants')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ParticipantModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Register to event
  Future<void> registerToEvent({
    required String eventId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    final participant = ParticipantModel(
      id: '',
      eventId: eventId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      status: 'pending',
      qrCode: null,
      checkInStatus: false,
      checkInTime: null,
      registeredAt: DateTime.now(),
    );

    await _firestore.collection('participants').add(participant.toFirestore());
  }

  // Check if user already registered to event
  Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    final querySnapshot = await _firestore
        .collection('participants')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Approve participant (Admin only)
  Future<void> approveParticipant(String participantId) async {
    final qrCode = _generateQRCode();

    await _firestore.collection('participants').doc(participantId).update({
      'status': 'approved',
      'qrCode': qrCode,
    });
  }

  // Reject participant (Admin only)
  Future<void> rejectParticipant(String participantId) async {
    await _firestore.collection('participants').doc(participantId).update({
      'status': 'rejected',
      'qrCode': null,
    });
  }

  // Check-in participant
  Future<void> checkInParticipant(String participantId) async {
    await _firestore.collection('participants').doc(participantId).update({
      'checkInStatus': true,
      'checkInTime': Timestamp.now(),
    });
  }

  // Cancel registration
  Future<void> cancelRegistration(String participantId) async {
    await _firestore.collection('participants').doc(participantId).delete();
  }

  // Generate unique QR Code
  String _generateQRCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(12, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Get participant by QR Code (for scanning)
  Future<ParticipantModel?> getParticipantByQRCode(String qrCode) async {
    final querySnapshot = await _firestore
        .collection('participants')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return ParticipantModel.fromFirestore(doc.data(), doc.id);
  }
}