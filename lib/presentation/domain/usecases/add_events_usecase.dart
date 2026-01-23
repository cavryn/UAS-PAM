  import '../repositories/event_repository.dart';

  class AddEventUsecase {
    final EventRepository repository;

    AddEventUsecase(this.repository);

Future<void> call({
  required String name,
  required String description,
  required String date,
  required String location,
  required int quota,
  required String createdBy,
  required String status,
}) async {
  await repository.addEvent(
    name: name,
    description: description,
    date: date,
    location: location,
    quota: quota,
    createdBy: createdBy,
    status: status,
  );
}
  }