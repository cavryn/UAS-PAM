import '../repositories/event_repository.dart';

class AddEventUsecase {
  final EventRepository repository;

  AddEventUsecase(this.repository);

  Future<void> call({
    required String name,
    required String description,
    required String date,
  }) async {
    await repository.addEvent(
      name: name,
      description: description,
      date: date,
    );
  }
}