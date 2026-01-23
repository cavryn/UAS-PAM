import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/participant.dart';

class ParticipantModel extends Participant {
  ParticipantModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.userName,
    required super.userEmail,
    super.userPhone,
    required super.status,
    super.qrCode,
    required super.checkInStatus,
    super.checkInTime,
    required super.registeredAt,
  });

  factory ParticipantModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ParticipantModel(
      id: id,
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'],
      status: json['status'] ?? 'pending',
      qrCode: json['qrCode'],
      checkInStatus: json['checkInStatus'] ?? false,
      checkInTime: (json['checkInTime'] as Timestamp?)?.toDate(),
      registeredAt: (json['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status,
      'qrCode': qrCode,
      'checkInStatus': checkInStatus,
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'registeredAt': Timestamp.fromDate(registeredAt),
    };
  }
}