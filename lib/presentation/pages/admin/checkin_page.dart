import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/camera_service.dart';

class CheckinPage extends StatelessWidget {
  final String registrationId;
  const CheckinPage({super.key, required this.registrationId});

  Future<void> checkin() async {
    final photoUrl = await CameraService.takeAndUploadPhoto();
    await FirebaseFirestore.instance.collection('attendance').add({
      'registration_id': registrationId,
      'checkin_time': DateTime.now().toIso8601String(),
      'photo_url': photoUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: Center(
        child: ElevatedButton(
          onPressed: checkin,
          child: const Text('Confirm Check-in'),
        ),
      ),
    );
  }
}
