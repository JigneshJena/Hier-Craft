import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AiConfigService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxString provider = 'gemini'.obs;
  final RxString model = 'gemini-1.5-flash'.obs;
  final RxString apiKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToAiConfig();
  }

  void _listenToAiConfig() {
    _firestore
        .collection('aiproviders')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .listen(( snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        provider.value = data['provider'] ?? 'gemini';
        model.value = data['model'] ?? 'gemini-1.5-flash';
        apiKey.value = data['apiKey'] ?? '';
        print("AI Config Updated from aiproviders: ${provider.value} - ${model.value}");
      } else {
        // Fallback to defaults or empty if no active provider found
        provider.value = 'none';
        model.value = 'none';
        apiKey.value = '';
        print("No active AI provider found in aiproviders");
      }
    });
  }


}
