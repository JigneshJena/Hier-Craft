import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/resume_service.dart';
import '../../data/models/resume_model.dart';
import '../../app/routes/app_routes.dart';

class ResumeBuilderController extends GetxController {
  final ResumeService _resumeService = Get.find<ResumeService>();

  // Form Step
  final currentStep = 0.obs;

  // Personal Info
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final summaryController = TextEditingController();

  // Education
  final educationList = <Map<String, String>>[].obs;
  
  // Experience
  final experienceList = <Map<String, String>>[].obs;

  // Skills
  final skills = <String>[].obs;
  final skillController = TextEditingController();

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    } else {
      generateResumeTemplate();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void addEducation() {
    educationList.add({'school': '', 'degree': '', 'year': ''});
  }

  void removeEducation(int index) {
    educationList.removeAt(index);
  }

  void addExperience() {
    experienceList.add({'company': '', 'role': '', 'duration': '', 'description': ''});
  }

  void removeExperience(int index) {
    experienceList.removeAt(index);
  }

  void addSkill() {
    if (skillController.text.isNotEmpty) {
      skills.add(skillController.text.trim());
      skillController.clear();
    }
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  Future<void> generateResumeTemplate() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final Map<String, dynamic> resumeData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'summary': summaryController.text,
        'education': educationList,
        'experience': experienceList,
        'skills': skills,
      };

      // In a real app, we'd use AI here to "polish" the details.
      // For now, we pass the data to the view which renders a beautiful template.
      
      Get.back(); // Close loading dialog
      Get.toNamed(AppRoutes.generatedResume, arguments: resumeData);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to generate resume: $e', 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    summaryController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
