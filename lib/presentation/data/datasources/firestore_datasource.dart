import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<EventModel>> getEvents() {
    return _firestore.collection('events').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addEvent({
  required String name,
  required String description,
  required String date,
  required String location,      
  required int quota,             
  required String createdBy,      
  required String status,         
}) async {
  final event = EventModel(
    id: '',
    name: name,
    description: description,
    date: date,
    location: location,
    quota: quota,
    createdBy: createdBy,
    status: status,
    createdAt: DateTime.now(),
  );

  await _firestore.collection('events').add(event.toFirestore());
}
  Future<bool> checkDuplicateEvent({
    required String name,
    required String date,
  }) async {
    final querySnapshot = await _firestore
        .collection('events')
        .where('name', isEqualTo: name)
        .where('date', isEqualTo: date)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}