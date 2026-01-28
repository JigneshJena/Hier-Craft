import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:get/get.dart';

class PdfGeneratorService extends GetxService {
  Future<void> generateAndShareResume(Map<String, dynamic> data) async {
    try {
      final pdf = await _generateResumePdf(data);
      final bytes = await pdf.save();
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'My Professional Resume');
    } catch (e) {
      Get.snackbar('Error', 'Failed to share resume: $e');
    }
  }

  Future<void> generateAndDownloadResume(Map<String, dynamic> data) async {
    try {
      final pdf = await _generateResumePdf(data);
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      Get.snackbar('Error', 'Failed to download/print resume: $e');
    }
  }

  Future<pw.Document> _generateResumePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    (data['name'] ?? 'YOUR NAME').toUpperCase(),
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '${data['email'] ?? ''} | ${data['phone'] ?? ''}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1, color: PdfColors.blueGrey900),
            pw.SizedBox(height: 20),

            // Summary
            _buildSectionHeader('PROFESSIONAL SUMMARY'),
            pw.Text(
              data['summary'] ?? '',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 20),

            // Experience
            _buildSectionHeader('WORK EXPERIENCE'),
            ...((data['experience'] as List? ?? []).map((exp) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(exp['role'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(exp['duration'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text(exp['company'] ?? '', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11, color: PdfColors.blue900)),
                  pw.SizedBox(height: 5),
                  pw.Text(exp['description'] ?? '', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ))),

            // Education
            _buildSectionHeader('EDUCATION'),
            ...((data['education'] as List? ?? []).map((edu) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${edu['degree']} - ${edu['school']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(edu['year'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ))),
            pw.SizedBox(height: 20),

            // Skills
            _buildSectionHeader('CORE COMPETENCIES'),
            pw.Wrap(
              spacing: 10,
              runSpacing: 5,
              children: (data['skills'] as List? ?? []).map((skill) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(skill.toString(), style: const pw.TextStyle(fontSize: 9)),
              )).toList(),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
        ),
        pw.SizedBox(height: 3),
        pw.Container(width: 40, height: 1.5, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
      ],
    );
  }
}
