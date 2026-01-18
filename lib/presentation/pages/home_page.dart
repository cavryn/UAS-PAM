import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/event_provider.dart';
import '../domain/entities/event.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Event'),
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
              return Card(
                child: ListTile(
                  title: Text(events[index].name),
                  subtitle: Text(events[index].date),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    context.go(
                      '/detail',
                      extra: events[index].name,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
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
                    // Hide keyboard
                    FocusScope.of(dialogContext).requestFocus(FocusNode());
                    
                    // Show date picker
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
                
                try {
                  await provider.addEvent(
                    name: nameController.text,
                    description: descriptionController.text,
                    date: dateController.text,
                  );
                  
                  Navigator.pop(dialogContext);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event berhasil ditambahkan!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
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