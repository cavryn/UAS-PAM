import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/firestore_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final FirestoreDatasource datasource;

  EventRepositoryImpl(this.datasource);

  @override
  Stream<List<Event>> getEvents() {
    return datasource.getEvents();
  }

  @override
  Future<void> addEvent({
    required String name,
    required String description,
    required String date,
  }) async {
    await datasource.addEvent(
      name: name,
      description: description,
      date: date,
    );
  }

  @override
  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  }) async {
    return await datasource.checkDuplicateEvent(
      name: name,
      date: date,
    );
  }
}