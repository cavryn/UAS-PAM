import '../repositories/event_repository.dart';

class GetEventsUsecase {
  final EventRepository repository;

  GetEventsUsecase(this.repository);

  Stream call() {
    return repository.getEvents();
  }
}
