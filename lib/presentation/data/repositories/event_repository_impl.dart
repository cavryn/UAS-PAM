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
}
