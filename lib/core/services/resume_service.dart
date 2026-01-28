import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../data/models/resume_model.dart';
import 'ai_api_service.dart';
import 'ai_config_service.dart';

/// Service for handling resume uploads and analysis
class ResumeService extends GetxService {
  final Logger _logger = Logger();
  final ImagePicker _imagePicker = ImagePicker();
  final AiApiService _aiService = Get.find<AiApiService>();

  /// Pick a PDF file from device storage
  Future<File?> pickPdfFile() async {
    try {
      _logger.i('Opening file picker for PDF');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        _logger.i('PDF file selected: ${file.path}');
        return file;
      }
      
      _logger.w('No PDF file selected');
      return null;
    } catch (e) {
      _logger.e('Error picking PDF file: $e');
      Get.snackbar('Error', 'Failed to pick PDF file');
      return null;
    }
  }

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      _logger.i('Opening gallery for image');
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        _logger.i('Image selected from gallery: ${file.path}');
        return file;
      }
      
      _logger.w('No image selected');
      return null;
    } catch (e) {
      _logger.e('Error picking image from gallery: $e');
      Get.snackbar('Error', 'Failed to pick image');
      return null;
    }
  }

  /// Capture image using camera
  Future<File?> captureImageFromCamera() async {
    try {
      _logger.i('Opening camera for capture');
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        _logger.i('Image captured from camera: ${file.path}');
        return file;
      }
      
      _logger.w('No image captured');
      return null;
    } catch (e) {
      _logger.e('Error capturing image from camera: $e');
      Get.snackbar('Error', 'Failed to capture image');
      return null;
    }
  }

  /// Extract text from PDF file
  /// Note: This is a placeholder. For actual PDF text extraction,
  /// you would need a package like 'pdf_text' or 'syncfusion_flutter_pdf'
  Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      _logger.i('Extracting text from PDF: ${pdfFile.path}');
      
      // TODO: Implement actual PDF text extraction
      // For now, we'll read the file and send it to AI which can handle PDF analysis
      final bytes = await pdfFile.readAsBytes();
      
      // Mock text extraction - replace with actual PDF parsing
      return '[PDF Content - Size: ${bytes.length} bytes]\n'
             'Note: PDF text extraction requires additional implementation';
    } catch (e) {
      _logger.e('Error extracting text from PDF: $e');
      throw Exception('Failed to extract PDF text');
    }
  }

  /// Extract text from image using OCR
  /// Note: For basic implementation, we'll send the image directly to AI
  /// For advanced OCR, consider using 'google_mlkit_text_recognition'
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      _logger.i('Preparing image for text extraction: ${imageFile.path}');
      
      // The AI API (especially Gemini) can handle image analysis directly
      // So we'll return the file path and handle it in the AI service
      return '[Image File: ${imageFile.path}]';
    } catch (e) {
      _logger.e('Error processing image: $e');
      throw Exception('Failed to process image');
    }
  }

  /// Analyze resume using AI
  Future<ResumeAnalysis> analyzeResume(String resumeText, {String? base64Data, String? mimeType}) async {
    try {
      final aiConfig = Get.find<AiConfigService>();
      _logger.i('Analyzing resume with AI (Global Config: ${aiConfig.provider.value})');
      
      // Call AI service for analysis
      final result = await _aiService.analyzeResume(
        resumeText: resumeText,
        apiKey: aiConfig.apiKey.value,
        provider: aiConfig.provider.value,
        model: aiConfig.model.value,
        base64Data: base64Data,
        mimeType: mimeType,
      );

      // Parse result into ResumeAnalysis model
      final analysis = ResumeAnalysis.fromJson(result);
      
      _logger.i('Resume analysis completed. Score: ${analysis.overallScore}');
      return analysis;
    } catch (e) {
      _logger.e('Error analyzing resume: $e');
      throw Exception('Failed to analyze resume');
    }
  }

  /// Complete resume analysis flow from file
  Future<ResumeAnalysis> analyzeResumeFromFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final extension = file.path.split('.').last.toLowerCase();
      
      String mimeType;
      if (extension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else {
        throw Exception('Unsupported file type: $extension');
      }

      // Analyze the file using multimodal AI
      return await analyzeResume('', base64Data: base64Data, mimeType: mimeType);
    } catch (e) {
      _logger.e('Error analyzing resume from file: $e');
      rethrow;
    }
  }

  /// Complete resume analysis with specific provider
  Future<ResumeAnalysis> analyzeResumeFromFileWithProvider(
    File file, {
    required String provider,
    required String model,
    required String apiKey,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final extension = file.path.split('.').last.toLowerCase();
      
      String mimeType;
      if (extension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else {
        throw Exception('Unsupported file type: $extension');
      }

      _logger.i('🔍 Analyzing resume with $provider ($model)');

      // Call AI service with specific provider
      final result = await _aiService.analyzeResume(
        resumeText: '',
        apiKey: apiKey,
        provider: provider,
        model: model,
        base64Data: base64Data,
        mimeType: mimeType,
      );

      // Parse result into ResumeAnalysis model
      final analysis = ResumeAnalysis.fromJson(result);
      
      _logger.i('✅ Resume analysis completed. Score: ${analysis.overallScore}');
      return analysis;
    } catch (e) {
      _logger.e('💥 Error analyzing resume from file: $e');
      rethrow;
    }
  }
}
