import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/ai_model.dart';
import '../../data/services/ai_provider_service.dart';

class AiProviderController extends GetxController {
  final AiProviderService _service = AiProviderService();

  // Reactive list of AI models
  final RxList<AiModel> aiModels = <AiModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    // Bind the stream to the reactive list
    aiModels.bindStream(
      _service.getAiProviders().handleError((error) {
        print("❌ Firestore Stream Error: $error");
        isLoading.value = false;
        Get.snackbar("Database Error", "Check your Firestore rules or internet connection.");
      })
    );
    
    // Listen to changes to update loading state
    aiModels.listen((models) {
      isLoading.value = false;
      if (models.isNotEmpty) {
        print("✅ Models sync: ${models.length} items found");
      }
    });
  }

  // Create or Update
  Future<void> saveModel(AiModel model) async {
    try {
      await _service.saveAiProvider(model);
      Get.snackbar('Success', 'AI Provider saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save AI Provider: $e');
    }
  }

  // Delete
  Future<void> deleteModel(String id) async {
    try {
      await _service.deleteAiProvider(id);
      Get.snackbar('Success', 'AI Provider deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete AI Provider: $e');
    }
  }
  
  // Toggle Active Status
  Future<void> toggleStatus(AiModel model) async {
    try {
      final bool willBeActive = !model.isActive;
      
      if (willBeActive) {
        // Deactivate all others first
        final batch = FirebaseFirestore.instance.batch();
        final collection = FirebaseFirestore.instance.collection('aiproviders');
        
        final otherDocs = await collection.where('isActive', isEqualTo: true).get();
        for (var doc in otherDocs.docs) {
          batch.update(doc.reference, {'isActive': false});
        }
        
        // Activate this one
        batch.update(collection.doc(model.id), {'isActive': true});
        await batch.commit();
        Get.snackbar('Success', '${model.provider} is now active');
      } else {
        // Just deactivate this one
        await _service.saveAiProvider(model.copyWith(isActive: false));
        Get.snackbar('Info', '${model.provider} deactivated');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle status: $e');
    }
  }

  // Delete All
  Future<void> deleteAllModels() async {
    try {
      await _service.deleteAllAiProviders();
      Get.snackbar('Success', 'All AI Providers deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete all providers: $e');
    }
  }
}
