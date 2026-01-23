import 'package:flutter/material.dart';
import '../../services/pdf_service.dart';

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PdfService.generateCertificate('User', 'Smart Event');
          },
          child: const Text('Download Certificate'),
        ),
      ),
    );
  }
}
