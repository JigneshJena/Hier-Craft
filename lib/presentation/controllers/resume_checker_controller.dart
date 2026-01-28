import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/resume_service.dart';
import '../../core/services/ai_config_service.dart';
import '../../data/models/resume_model.dart';
import '../../data/models/ai_provider_model.dart';

class ResumeCheckerController extends GetxController {
  final ResumeService _resumeService = Get.find<ResumeService>();
  final AiConfigService _aiConfig = Get.find<AiConfigService>();
  final Logger _logger = Logger();

  final Rx<ResumeAnalysis?> analysis = Rx<ResumeAnalysis?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  
  // AI Provider Selection
  final RxList<AiProviderModel> aiProviders = <AiProviderModel>[].obs;
  final Rx<AiProviderModel?> selectedProvider = Rx<AiProviderModel?>(null);
  final RxBool isLoadingProviders = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAiProviders();
  }

  /// Load available AI providers from Firestore
  Future<void> _loadAiProviders() async {
    try {
      isLoadingProviders.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('aiproviders')
          .where('isActive', isEqualTo: true)
          .get();

      aiProviders.value = snapshot.docs
          .map((doc) => AiProviderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Set default provider (first active or global config)
      if (aiProviders.isNotEmpty) {
        selectedProvider.value = aiProviders.firstWhere(
          (p) => p.provider.toLowerCase() == _aiConfig.provider.value.toLowerCase(),
          orElse: () => aiProviders.first,
        );
      }

      _logger.i('✅ Loaded ${aiProviders.length} AI providers for resume checker');
    } catch (e) {
      _logger.e('Error loading AI providers: $e');
    } finally {
      isLoadingProviders.value = false;
    }
  }

  /// Pick PDF file and analyze
  Future<void> pickPdfFile() async {
    try {
      errorMessage.value = '';
      final file = await _resumeService.pickPdfFile();
      
      if (file != null) {
        selectedFile.value = file;
        await analyzeFile(file);
      }
    } catch (e) {
      _logger.e('Error in pickPdfFile: $e');
      errorMessage.value = 'Failed to process PDF file';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick image from gallery and analyze
  Future<void> pickImageFromGallery() async {
    try {
      errorMessage.value = '';
      final file = await _resumeService.pickImageFromGallery();
      
      if (file != null) {
        selectedFile.value = file;
        await analyzeFile(file);
      }
    } catch (e) {
      _logger.e('Error in pickImageFromGallery: $e');
      errorMessage.value = 'Failed to process image';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Capture image from camera and analyze
  Future<void> captureImageFromCamera() async {
    try {
      errorMessage.value = '';
      final file = await _resumeService.captureImageFromCamera();
      
      if (file != null) {
        selectedFile.value = file;
        await analyzeFile(file);
      }
    } catch (e) {
      _logger.e('Error in captureImageFromCamera: $e');
      errorMessage.value = 'Failed to capture image';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Analyze the selected file
  Future<void> analyzeFile(File file) async {
    try {
      // Check if provider is selected
      if (selectedProvider.value == null) {
        Get.snackbar(
          'No AI Provider',
          'Please select an AI provider first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isAnalyzing.value = true;
      errorMessage.value = '';
      
      _logger.i('Starting resume analysis for: ${file.path}');
      _logger.i('🤖 Using AI: ${selectedProvider.value!.provider} - ${selectedProvider.value!.model}');
      
      final result = await _resumeService.analyzeResumeFromFileWithProvider(
        file,
        provider: selectedProvider.value!.provider,
        model: selectedProvider.value!.model,
        apiKey: selectedProvider.value!.apiKey,
      );
      analysis.value = result;
      
      Get.snackbar(
        'Success',
        'Resume analyzed successfully! Score: ${result.overallScore}/100',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to dedicated analysis page
      Get.toNamed('/resume-analysis', arguments: result);
    } catch (e) {
      _logger.e('Error analyzing file: $e');
      errorMessage.value = 'Failed to analyze resume: ${e.toString()}';
      analysis.value = null;
      
      Get.snackbar(
        'Analysis Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Reset the analysis
  void reset() {
    analysis.value = null;
    selectedFile.value = null;
    errorMessage.value = '';
    isAnalyzing.value = false;
  }

  /// Display file picker options bottom sheet
  void showFilePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Resume',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.picture_as_pdf,
              title: 'PDF Document',
              subtitle: 'Upload resume as PDF',
              onTap: () {
                Get.back();
                pickPdfFile();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.photo_library,
              title: 'From Gallery',
              subtitle: 'Choose image from gallery',
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Capture resume with camera',
              onTap: () {
                Get.back();
                captureImageFromCamera();
              },
            ),
          ],
        ),
      ),
      isDismissible: true,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Get.theme.colorScheme.primary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Get.theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
