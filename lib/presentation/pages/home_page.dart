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
    );
  }
}
