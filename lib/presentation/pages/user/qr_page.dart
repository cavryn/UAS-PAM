import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatelessWidget {
  final String registrationId;
  const QrPage({super.key, required this.registrationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My QR Code')),
      body: Center(
        child: QrImageView(
          data: registrationId,
          size: 200,
        ),
      ),
    );
  }
}
