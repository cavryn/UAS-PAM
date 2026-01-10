import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String eventName;

  const EventDetailPage({
    super.key,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deskripsi event masih dummy. '
              'Nanti akan diambil dari database.',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur registrasi akan ditambahkan'),
                  ),
                );
              },
              child: const Text('Daftar Event'),
            ),
          ],
        ),
      ),
    );
  }
}