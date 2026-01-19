class Participant {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String status; // 'pending', 'approved', 'rejected'
  final String? qrCode;
  final bool checkInStatus;
  final DateTime? checkInTime;
  final DateTime registeredAt;

  Participant({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.status,
    this.qrCode,
    required this.checkInStatus,
    this.checkInTime,
    required this.registeredAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCheckedIn => checkInStatus;
}