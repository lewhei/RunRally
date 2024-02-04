import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:runrally/models/run.dart';

class RunRepository {
  final CollectionReference runCollection = FirebaseFirestore.instance.collection('runs');

  Future<void> saveRun(Run run) {
    return runCollection.add(run.toMap());
  }
}