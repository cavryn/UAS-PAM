// lib/services/certificate_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class CertificateService {
  Future<File> generateCertificate({
    required String participantName,
    required String eventName,
    required String eventDate,
    required String certificateNumber,
  }) async {
    final pdf = pw.Document();

    // Load font untuk support bahasa Indonesia
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontItalic = await PdfGoogleFonts.openSansItalic();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.blue900,
                width: 10,
              ),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.blue700,
                  width: 2,
                ),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    pw.Text(
                      'SERTIFIKAT',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 48,
                        color: PdfColors.blue900,
                        letterSpacing: 8,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      width: 200,
                      height: 3,
                      color: PdfColors.blue900,
                    ),
                    pw.SizedBox(height: 30),

                    // Body text
                    pw.Text(
                      'Diberikan kepada:',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 18,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 15),

                    // Participant name
                    pw.Text(
                      participantName.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 36,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 25),

                    // Event description
                    pw.Container(
                      width: 500,
                      child: pw.Text(
                        'Atas partisipasi dan kehadirannya dalam acara',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 16,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 15),

                    // Event name
                    pw.Container(
                      width: 600,
                      child: pw.Text(
                        '"$eventName"',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 24,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Date
                    pw.Text(
                      'Tanggal: $eventDate',
                      style: pw.TextStyle(
                        font: fontItalic,
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 40),

                    // Signature section
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 150,
                              height: 1,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Ketua Panitia',
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 150,
                              height: 1,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Penyelenggara',
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 30),

                    // Certificate number
                    pw.Text(
                      'No. Sertifikat: $certificateNumber',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File(
        '${output.path}/certificate_${participantName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> printCertificate({
    required String participantName,
    required String eventName,
    required String eventDate,
    required String certificateNumber,
  }) async {
    final file = await generateCertificate(
      participantName: participantName,
      eventName: eventName,
      eventDate: eventDate,
      certificateNumber: certificateNumber,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => file.readAsBytesSync(),
    );
  }

  Future<void> shareCertificate({
    required String participantName,
    required String eventName,
    required String eventDate,
    required String certificateNumber,
  }) async {
    final file = await generateCertificate(
      participantName: participantName,
      eventName: eventName,
      eventDate: eventDate,
      certificateNumber: certificateNumber,
    );

    await Printing.sharePdf(
      bytes: file.readAsBytesSync(),
      filename: 'Sertifikat_${participantName.replaceAll(' ', '_')}.pdf',
    );
  }
}