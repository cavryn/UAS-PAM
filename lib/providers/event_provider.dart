import 'package:flutter/foundation.dart';
import '/presentation/domain/usecases/add_events_usecase.dart';
import '/presentation/domain/usecases/get_events_usecase.dart';


class EventProvider extends ChangeNotifier {
  final GetEventsUsecase _getEventsUsecase;
  final AddEventUsecase _addEventUsecase;

  EventProvider(this._getEventsUsecase, this._addEventUsecase);

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
}