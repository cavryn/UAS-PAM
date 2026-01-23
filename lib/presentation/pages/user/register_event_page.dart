import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterEventPage extends StatelessWidget {
  final String eventId;
  const RegisterEventPage({super.key, required this.eventId});

  Future<void> register() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('registrations').add({
      'event_id': eventId,
      'user_id': user.uid,
      'status': 'pending',
      'registered_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Event')),
      body: Center(
        child: ElevatedButton(
          onPressed: register,
          child: const Text('Confirm Registration'),
        ),
      ),
    );
  }
}
