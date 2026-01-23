import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/participant.dart';
import '../../../providers/participant_provider.dart';


class ParticipantApprovalPage extends StatelessWidget {
  final String? eventId;
  final String? eventName;

  const ParticipantApprovalPage({
    Key? key,
    this.eventId,
    this.eventName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName != null 
            ? 'Kelola Peserta - $eventName' 
            : 'Kelola Pendaftaran Peserta'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<Participant>>(
        stream: eventId != null
            ? context.read<ParticipantProvider>().getParticipantsByEvent(eventId!)
            : context.read<ParticipantProvider>().getPendingParticipants(),
        builder: (context, snapshot) {
          print('Connection State: ${snapshot.connectionState}');
          print('Has Data: ${snapshot.hasData}');
          print('Has Error: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            print('Data length: ${snapshot.data!.length}');
          }

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 100, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          // Filter pending participants if showing all
          final participants = eventId != null
              ? snapshot.data!
              : snapshot.data!.where((p) => p.status == 'pending').toList();

          // Empty state
          if (participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, 
                       size: 100, 
                       color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada pendaftaran yang menunggu',
                       style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Semua pendaftaran sudah diproses',
                       style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                ],
              ),
            );
          }

          // Data available
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return ParticipantCard(participant: participant);
            },
          );
        },
      ),
    );
  }
}

class ParticipantCard extends StatelessWidget {
  final Participant participant;

  const ParticipantCard({Key? key, required this.participant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(),
            SizedBox(height: 12),

            // Participant Info
            _buildInfoRow(Icons.person, 'Nama', participant.userName),
            SizedBox(height: 8),
            _buildInfoRow(Icons.email, 'Email', participant.userEmail),
            if (participant.userPhone != null) ...[
              SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'Telepon', participant.userPhone!),
            ],
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time, 
              'Waktu Daftar', 
              _formatDate(participant.registeredAt)
            ),

            // Show action buttons only for pending status
            if (participant.status == 'pending') ...[
              SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (participant.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Menunggu Persetujuan';
        icon = Icons.pending;
        break;
      case 'approved':
        color = Colors.green;
        text = 'Disetujui';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Ditolak';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = participant.status;
        icon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleApproval(context, true),
            icon: Icon(Icons.check_circle),
            label: Text('Setujui'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleApproval(context, false),
            icon: Icon(Icons.cancel),
            label: Text('Tolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleApproval(BuildContext context, bool isApproved) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproved ? 'Setujui Pendaftaran?' : 'Tolak Pendaftaran?'),
        content: Text(
          isApproved
              ? 'Peserta "${participant.userName}" akan dapat mengikuti event ini.'
              : 'Peserta "${participant.userName}" tidak akan dapat mengikuti event ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? Colors.green : Colors.red,
            ),
            child: Text(isApproved ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<ParticipantProvider>();
        final bool success = isApproved
            ? await provider.approveParticipant(participant.id)
            : await provider.rejectParticipant(participant.id);

        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isApproved 
                    ? 'Pendaftaran berhasil disetujui' 
                    : 'Pendaftaran ditolak'
              ),
              backgroundColor: isApproved ? Colors.green : Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Terjadi kesalahan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}