import '../repositories/event_repository.dart';

class CheckDuplicateEventUsecase {
  final EventRepository repository;

  CheckDuplicateEventUsecase(this.repository);

  Future<bool> call({
    required String name,
    required String date,
  }) async {
    return await repository.checkDuplicateEvent(
      name: name,
      date: date,
    );
  }
}