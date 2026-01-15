import '../event.dart';

abstract class EventRepository {
  Stream<List<Event>> getEvents();
}
