import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_model.dart';

class AiProviderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'aiproviders';

  // Read: Stream for real-time updates
  Stream<List<AiModel>> getAiProviders() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AiModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Create/Update: Upsert function
  Future<void> saveAiProvider(AiModel model) async {
    await _firestore.collection(_collection).doc(model.id).set(model.toMap());
  }

  // Delete
  Future<void> deleteAiProvider(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Delete All (Emergency Cleanup)
  Future<void> deleteAllAiProviders() async {
    final snapshot = await _firestore.collection(_collection).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
