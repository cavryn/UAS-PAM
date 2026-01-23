import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '/providers/attendance_provider.dart';
import '/providers/auth_provider.dart';

class AttendancePage extends StatefulWidget {
  final String eventId;
  final String eventName;

  const AttendancePage({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkExistingAttendance();
  }

  Future<void> _checkExistingAttendance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await attendanceProvider.checkMyAttendance(
        widget.eventId,
        authProvider.user!.id,
      );
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk absensi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Izin kamera ditolak. Buka pengaturan untuk mengaktifkan',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Buka Pengaturan',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    // Cek dan minta izin kamera
    final cameraStatus = await Permission.camera.status;

    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      await _requestCameraPermission();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
        requestFullMetadata: false,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diambil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengambilan foto dibatalkan'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka kamera: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto terlebih dahulu')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await attendanceProvider.submitAttendance(
      eventId: widget.eventId,
      participantId: authProvider.user!.id,
      participantName: authProvider.user!.name,
      participantEmail: authProvider.user!.email,
      photoPath: _imageFile!.path,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Absensi berhasil dikirim! Menunggu persetujuan admin',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengirim absensi: ${attendanceProvider.error}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kehadiran'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke halaman sebelumnya atau home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.myAttendance != null) {
            return _buildAttendanceStatus(provider.myAttendance!.status);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.event, size: 48, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(
                          widget.eventName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Ambil Foto Selfie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Untuk verifikasi kehadiran, mohon ambil foto selfie Anda dengan kamera',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_imageFile != null)
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'Tekan tombol di bawah\nuntuk mengambil foto',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    _imageFile == null
                        ? 'Ambil Foto dengan Kamera'
                        : 'Ambil Ulang',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _imageFile == null || _isSubmitting
                      ? null
                      : _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim Absensi'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceStatus(String status) {
    IconData icon;
    Color color;
    String message;
    String description;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        message = 'Absensi Disetujui';
        description = 'Kehadiran Anda telah diverifikasi oleh admin';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        message = 'Absensi Ditolak';
        description = 'Mohon hubungi admin untuk informasi lebih lanjut';
        break;
      default:
        icon = Icons.pending;
        color = Colors.orange;
        message = 'Menunggu Persetujuan';
        description = 'Absensi Anda sedang dalam proses verifikasi';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Home'),
              style: ElevatedButton.styleFrom(
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
}