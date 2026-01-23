import '../entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
  
  Future<void> addEvent({
  required String name,
  required String description,
  required String date,
  required String location,     
  required int quota,            
  required String createdBy,      
  required String status,         
});

  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  });
}