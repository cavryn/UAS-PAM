import 'package:flutter/foundation.dart';
import '/presentation/domain/usecases/add_events_usecase.dart';
import '/presentation/domain/usecases/get_events_usecase.dart';
import '/presentation/domain/usecases/check_duplicate_event_usecase.dart';

class EventProvider extends ChangeNotifier {
  final GetEventsUsecase _getEventsUsecase;
  final AddEventUsecase _addEventUsecase;
  final CheckDuplicateEventUsecase _checkDuplicateEventUsecase;

  EventProvider(
    this._getEventsUsecase,
    this._addEventUsecase,
    this._checkDuplicateEventUsecase,
  );

  Stream get events => _getEventsUsecase();

Future<void> addEvent({
  required String name,
  required String description,
  required String date,
  required String location,
  required int quota,
  required String createdBy,
  required String status,
}) async {
  await _addEventUsecase(
    name: name,
    description: description,
    date: date,
    location: location,
    quota: quota,
    createdBy: createdBy,
    status: status,
  );
}

  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  }) async {
    return await _checkDuplicateEventUsecase(
      name: name,
      date: date,
    );
  }
}      