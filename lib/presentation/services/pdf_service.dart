import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateCertificate(String name, String event) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Center(
          child: pw.Text('Certificate\n$name\nfor attending\n$event'),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}
