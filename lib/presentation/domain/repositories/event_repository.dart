import '../entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
  
  Future<void> addEvent({
    required String name,
    required String description,
    required String date,
  });

  // Method baru untuk cek duplikasi
  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  });
}