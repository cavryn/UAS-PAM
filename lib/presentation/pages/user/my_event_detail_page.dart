import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/attendance.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../services/certificate_service.dart';

class MyEventDetailPage extends StatefulWidget {
  final Participant participant;

  const MyEventDetailPage({Key? key, required this.participant}) : super(key: key);

  @override
  State<MyEventDetailPage> createState() => _MyEventDetailPageState();
}

class _MyEventDetailPageState extends State<MyEventDetailPage> {
  final CertificateService _certificateService = CertificateService();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _checkAttendanceStatus();
  }

  Future<void> _checkAttendanceStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    if (authProvider.user != null && widget.participant.status == 'approved') {
      await attendanceProvider.checkMyAttendance(
        widget.participant.eventId,
        authProvider.user!.id, // CHANGED from uid to id
      );
    }
  }

  Future<void> _goToAttendance() async {
    final eventId = widget.participant.eventId;
    final eventName = Uri.encodeComponent(widget.participant.eventName ?? 'Event');
    context.go('/attendance/$eventId/$eventName');
  }

  void _showAttendanceStatus(Attendance attendance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              attendance.status == 'approved'
                  ? Icons.check_circle
                  : attendance.status == 'rejected'
                      ? Icons.cancel
                      : Icons.pending,
              color: attendance.status == 'approved'
                  ? Colors.green
                  : attendance.status == 'rejected'
                      ? Colors.red
                      : Colors.orange,
            ),
            const SizedBox(width: 10),
            const Text('Status Absensi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${attendance.status.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: attendance.status == 'approved'
                    ? Colors.green
                    : attendance.status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text('Waktu Check-in: ${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(attendance.checkInTime)}'),
            if (attendance.adminNotes != null) ...[
              const SizedBox(height: 10),
              const Text(
                'Catatan Admin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(attendance.adminNotes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCertificate(Attendance attendance) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final certificateNumber = 'CERT-${attendance.eventId.substring(0, 8).toUpperCase()}-${attendance.participantId.substring(0, 6).toUpperCase()}';

      await _certificateService.shareCertificate(
        participantName: attendance.participantName,
        eventName: widget.participant.eventName ?? 'Event',
        eventDate: dateFormat.format(attendance.checkInTime),
        certificateNumber: certificateNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sertifikat berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat sertifikat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket Saya'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              _buildStatusCard(),
              const SizedBox(height: 20),

              // Attendance & Certificate Section (hanya untuk approved)
              if (widget.participant.status == 'approved') ...[
                _buildAttendanceSection(),
                const SizedBox(height: 20),
              ],

              // QR Code (hanya tampil jika approved)
              if (widget.participant.status == 'approved') ...[
                _buildQRCodeSection(),
                const SizedBox(height: 20),
              ],

              // Participant Info
              _buildInfoCard(),
              const SizedBox(height: 20),

              // Check-in Info
              if (widget.participant.checkInStatus) _buildCheckInInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final attendance = attendanceProvider.myAttendance;

        if (attendance == null) {
          // Belum absen
          return Card(
            elevation: 4,
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.blue[700]),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum Absen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lakukan absensi untuk mendapatkan sertifikat',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _goToAttendance,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Absen Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Sudah absen - tampilkan status
        Color statusColor;
        IconData statusIcon;
        String statusText;
        String statusMessage;

        switch (attendance.status) {
          case 'pending':
            statusColor = Colors.orange;
            statusIcon = Icons.pending;
            statusText = 'Menunggu Verifikasi';
            statusMessage = 'Absensi Anda sedang ditinjau oleh admin';
            break;
          case 'approved':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            statusText = 'Absensi Disetujui';
            statusMessage = 'Sertifikat Anda sudah tersedia untuk diunduh';
            break;
          case 'rejected':
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
            statusText = 'Absensi Ditolak';
            statusMessage = 'Silakan hubungi admin untuk informasi lebih lanjut';
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.info;
            statusText = attendance.status;
            statusMessage = '';
        }

        return Card(
          elevation: 4,
          color: statusColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(statusIcon, size: 48, color: statusColor),
                const SizedBox(height: 12),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Lihat Detail
                    OutlinedButton.icon(
                      onPressed: () => _showAttendanceStatus(attendance),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: statusColor,
                        side: BorderSide(color: statusColor),
                      ),
                    ),
                    
                    // Tombol Download Sertifikat (hanya jika approved)
                    if (attendance.status == 'approved') ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isGenerating
                            ? null
                            : () => _downloadCertificate(attendance),
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download),
                        label: Text(
                            _isGenerating ? 'Membuat...' : 'Sertifikat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                    
                    // Tombol Absen Ulang (jika rejected)
                    if (attendance.status == 'rejected') ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _goToAttendance,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Absen Ulang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    Color color;
    String title;
    String message;
    IconData icon;

    switch (widget.participant.status) {
      case 'pending':
        color = Colors.orange;
        title = 'Menunggu Persetujuan';
        message = 'Pendaftaran Anda sedang ditinjau oleh admin';
        icon = Icons.pending;
        break;
      case 'approved':
        color = Colors.green;
        title = 'Pendaftaran Disetujui!';
        message = 'Anda dapat mengikuti event ini. Tunjukkan QR Code saat check-in.';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        title = 'Pendaftaran Ditolak';
        message = 'Maaf, pendaftaran Anda tidak dapat disetujui';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        title = widget.participant.status;
        message = '';
        icon = Icons.info;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    if (widget.participant.qrCode == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              Icon(Icons.qr_code, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'QR Code belum tersedia',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'QR Code Check-In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: widget.participant.qrCode!,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tunjukkan QR Code ini saat check-in',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.participant.checkInStatus) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sudah Check-in',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Peserta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Nama', widget.participant.userName),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', widget.participant.userEmail),
            if (widget.participant.userPhone != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, 'Telepon', widget.participant.userPhone!),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Terdaftar',
              _formatDate(widget.participant.registeredAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInInfo() {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Informasi Check-In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Waktu Check-in',
              widget.participant.checkInTime != null
                  ? _formatDateTime(widget.participant.checkInTime!)
                  : '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, $hour:$minute';
  }
}