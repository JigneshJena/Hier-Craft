import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/domain_model.dart';

class DomainService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'domains';

  // Get all domains stream
  Stream<List<DomainModel>> getDomainsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DomainModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get active domains only
  Stream<List<DomainModel>> getActiveDomainsStream() {
    print('🔍 DomainService: Fetching active domains from Firestore...');
    
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          print('📊 DomainService: Received ${snapshot.docs.length} domain documents');
          final domains = snapshot.docs
              .map((doc) {
                try {
                  return DomainModel.fromMap(doc.data(), doc.id);
                } catch (e) {
                  print('❌ Error parsing domain ${doc.id}: $e');
                  return null;
                }
              })
              .where((d) => d != null)
              .cast<DomainModel>()
              .toList();
          print('✅ DomainService: Parsed ${domains.length} valid domains');
          return domains;
        })
        .handleError((error) {
          print('🚨 DomainService Error: $error');
          return <DomainModel>[];
        });
  }

  // Get domains by category
  Stream<List<DomainModel>> getDomainsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DomainModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add new domain
  Future<String> addDomain(DomainModel domain) async {
    try {
      final docRef = await _firestore.collection(_collection).add(domain.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update domain
  Future<void> updateDomain(String id, DomainModel domain) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(domain.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Toggle domain active status
  Future<void> toggleDomainStatus(String id, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete domain
  Future<void> deleteDomain(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get domain by ID
  Future<DomainModel?> getDomainById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return DomainModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search domains
  Stream<List<DomainModel>> searchDomains(String query) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DomainModel.fromMap(doc.data(), doc.id))
            .where((domain) =>
                domain.name.toLowerCase().contains(query.toLowerCase()) ||
                domain.category.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((cat) => cat != null)
          .toSet()
          .toList();
      return categories.cast<String>();
    } catch (e) {
      return [];
    }
  }
}
