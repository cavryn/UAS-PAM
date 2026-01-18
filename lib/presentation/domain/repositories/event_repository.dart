import '../entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
  
  Future<void> addEvent({
    required String name,
    required String description,
    required String date,
  });
}