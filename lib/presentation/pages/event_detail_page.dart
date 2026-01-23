import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/participant_provider.dart';
import '../domain/entities/event.dart';
import 'admin/participant_approval_page.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final authProvider = context.read<AuthProvider>();
    final participantProvider = context.read<ParticipantProvider>();

    if (authProvider.currentUser != null) {
      final isRegistered = await participantProvider.isUserRegistered(
        eventId: widget.event.id,
        userId: authProvider.currentUser!.id,
      );

      setState(() {
        _isRegistered = isRegistered;
        _isCheckingRegistration = false;
      });
    } else {
      setState(() {
        _isCheckingRegistration = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();
    final participantProvider = context.read<ParticipantProvider>();

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = authProvider.currentUser!;

    final success = await participantProvider.registerToEvent(
      eventId: widget.event.id,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userPhone: user.phone,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isRegistered = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Menunggu persetujuan admin.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(participantProvider.error ?? 'Pendaftaran gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Event')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Banner (placeholder)
            Container(
              height: 200,
              color: Colors.indigo.shade100,
              child: const Center(
                child: Icon(Icons.event, size: 80, color: Colors.indigo),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Info Cards
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Tanggal',
                    value: widget.event.date,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Lokasi',
                    value: widget.event.location,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.people,
                    title: 'Kuota',
                    value: '${widget.event.quota} peserta',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    title: 'Status',
                    value: _getStatusText(widget.event.status),
                    valueColor: _getStatusColor(widget.event.status),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final authProvider = context.watch<AuthProvider>();
    final participantProvider = context.watch<ParticipantProvider>();

    if (_isCheckingRegistration) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.isAdmin) {
      // Admin sees Manage Participants button
      return Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParticipantApprovalPage(
                  eventId: widget.event.id,
                  eventName: widget.event.name,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.indigo,
          ),
          child: const Text('Kelola Peserta'),
        ),
      );
    }

    // User sees Register button
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isRegistered
            ? null
            : (participantProvider.isLoading ? null : _handleRegister),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _isRegistered ? Colors.grey : Colors.indigo,
        ),
        child: participantProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isRegistered ? 'Sudah Terdaftar' : 'Daftar Event',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'published':
        return 'Dibuka';
      case 'ongoing':
        return 'Berlangsung';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'published':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
