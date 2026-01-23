import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/participant.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/participant_provider.dart';
import 'my_event_detail_page.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Saya'),
          backgroundColor: Colors.indigo,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.login, size: 100, color: Colors.grey),
              SizedBox(height: 16),
              Text('Silakan login terlebih dahulu'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Saya'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<List<Participant>>(
        stream: context
            .read<ParticipantProvider>()
            .getParticipantsByUser(authProvider.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 100, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.event_busy, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada event yang didaftar',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final participants = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return MyEventCard(participant: participant);
            },
          );
        },
      ),
    );
  }
}

class MyEventCard extends StatelessWidget {
  final Participant participant;

  const MyEventCard({Key? key, required this.participant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyEventDetailPage(participant: participant),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              const Text(
                'Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Status Badge
              _buildStatusBadge(),
              const SizedBox(height: 12),

              // Registration Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Terdaftar: ${_formatDate(participant.registeredAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              // Check-in status
              if (participant.checkInStatus) ...[
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Sudah Check-in',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}