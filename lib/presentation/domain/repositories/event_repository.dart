import '../entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
  
  Future<void> addEvent({
  required String name,
  required String description,
  required String date,
  required String location,      // TAMBAH
  required int quota,             // TAMBAH
  required String createdBy,      // TAMBAH
  required String status,         // TAMBAH
});

  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  });
}