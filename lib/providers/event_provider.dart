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
  }) async {
    await _addEventUsecase(
      name: name,
      description: description,
      date: date,
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