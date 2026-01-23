// lib/pages/user/certificate_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/providers/attendance_provider.dart';
import '/providers/auth_provider.dart';
import '../../services/certificate_service.dart';
import '../../domain/entities/attendance.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({Key? key}) : super(key: key);

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final CertificateService _certificateService = CertificateService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadMyAttendances();
  }

  Future<void> _loadMyAttendances() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    if (authProvider.user != null) {
      await attendanceProvider.loadMyAttendances(
        authProvider.user!.id,
      ); // CHANGED from uid to id
    }
  }

  Future<void> _downloadCertificate(
    Attendance attendance,
    String eventName,
  ) async {
    setState(() {
      _isGenerating = true;
    });
    try {
      final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final certificateNumber =
          'CERT-${attendance.eventId.substring(0, 8).toUpperCase()}-${attendance.participantId.substring(0, 6).toUpperCase()}';

      await _certificateService.shareCertificate(
        participantName: attendance.participantName,
        eventName: eventName,
        eventDate: dateFormat.format(attendance.checkInTime),
        certificateNumber: certificateNumber,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertifikat berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat sertifikat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikat Saya'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final approvedAttendances = provider.myAttendances
              .where((a) => a.status == 'approved')
              .toList();

          if (approvedAttendances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada sertifikat tersedia',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Ikuti acara dan selesaikan absensi untuk mendapatkan sertifikat',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMyAttendances,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: approvedAttendances.length,
              itemBuilder: (context, index) {
                final attendance = approvedAttendances[index];
                return _buildCertificateCard(attendance);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(Attendance attendance) {
    final dateFormat = DateFormat('dd MMM yyyy');
    // Untuk demo, kita gunakan eventId sebagai nama event
    // Dalam implementasi sebenarnya, Anda perlu fetch event detail
    final eventName = 'Event ${attendance.eventId.substring(0, 8)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SERTIFIKAT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attendance.participantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(attendance.checkInTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Terverifikasi',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating
                      ? null
                      : () => _downloadCertificate(attendance, eventName),
                  icon: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _isGenerating
                        ? 'Membuat Sertifikat...'
                        : 'Download Sertifikat',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
