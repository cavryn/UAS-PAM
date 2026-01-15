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
}
