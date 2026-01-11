import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      'Seminar Teknologi AI',
      'Workshop Flutter',
      'Webinar Cyber Security',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Event'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(events[index]),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                context.go(
                  '/detail',
                  extra: events[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}