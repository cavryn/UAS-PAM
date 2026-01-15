import 'package:flutter/material.dart';
import '../presentation/domain/usecases/get_events_usecase.dart';

class EventProvider extends ChangeNotifier {
  final GetEventsUsecase _getEventsUsecase;

  EventProvider(this._getEventsUsecase);

  Stream get events => _getEventsUsecase();
}
