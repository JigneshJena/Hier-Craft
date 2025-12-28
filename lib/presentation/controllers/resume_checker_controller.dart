import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../core/services/resume_service.dart';
import '../../data/models/resume_model.dart';

class ResumeCheckerController extends GetxController {
  final ResumeService _resumeService = Get.find<ResumeService>();
  final Logger _logger = Logger();

  final Rx<ResumeAnalysis?> analysis = Rx<ResumeAnalysis?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);

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
      isAnalyzing.value = true;
      errorMessage.value = '';
      
      _logger.i('Starting resume analysis for: ${file.path}');
      
      final result = await _resumeService.analyzeResumeFromFile(file);
      analysis.value = result;
      
      Get.snackbar(
        'Success',
        'Resume analyzed successfully! Score: ${result.overallScore}/100',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
