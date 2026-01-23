import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/event_provider.dart';
import '/providers/auth_provider.dart';
import '../domain/entities/event.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EventProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Event'),
        actions: [
          if (authProvider.isAdmin)
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'Admin Dashboard',
              onPressed: () {
                context.go('/admin/dashboard');
              },
            ),
          // Profile/Logout button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: provider.events as Stream<List<Event>>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada event'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    context.go('/detail', extra: event);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(event.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.date,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kuota: ${event.quota} peserta',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddEventDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'draft':
        color = Colors.grey;
        text = 'Draft';
        break;
      case 'published':
        color = Colors.green;
        text = 'Dibuka';
        break;
      case 'ongoing':
        color = Colors.orange;
        text = 'Berlangsung';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Selesai';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(authProvider.currentUser?.name ?? 'User'),
                subtitle: Text(authProvider.currentUser?.email ?? ''),
              ),
              const Divider(),
              // Admin Dashboard menu item (hanya untuk admin)
              if (authProvider.isAdmin)
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Admin Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/dashboard');
                  },
                ),
              if (authProvider.isAdmin) const Divider(),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Event Saya'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/my-events');
                },
              ),
              ListTile(
                leading: const Icon(Icons.card_membership),
                title: const Text('Sertifikat Saya'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/certificates');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();
    final quotaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Event'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Event',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama event tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quotaController,
                  decoration: const InputDecoration(
                    labelText: 'Kuota Peserta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kuota tidak boleh kosong';
                    }
                    final quota = int.tryParse(value);
                    if (quota == null || quota <= 0) {
                      return 'Kuota harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    hintText: '2025-02-01',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal tidak boleh kosong';
                    }
                    return null;
                  },
                  onTap: () async {
                    FocusScope.of(dialogContext).requestFocus(FocusNode());
                    
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    
                    if (date != null) {
                      dateController.text = date.toString().split(' ')[0];
                    }
                  },
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final provider = context.read<EventProvider>();
                final authProvider = context.read<AuthProvider>();
                
                try {
                  final isDuplicate = await provider.checkDuplicateEvent(
                    name: nameController.text,
                    date: dateController.text,
                  );
                  
                  if (isDuplicate) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event dengan nama dan tanggal yang sama sudah ada!'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Note: addEvent needs to be updated to accept new fields
                  await provider.addEvent(
                    name: nameController.text,
                    description: descriptionController.text,
                    date: dateController.text,
                    location: locationController.text,
                    quota: int.parse(quotaController.text),
                    createdBy: authProvider.currentUser?.id ?? '',
                    status: 'published',
                  );
                  
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}