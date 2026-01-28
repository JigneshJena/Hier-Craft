import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/domain_model.dart';
import '../../data/services/domain_service.dart';

class DomainManagementController extends GetxController {
  final DomainService _domainService = Get.put(DomainService());

  // Observable lists
  final RxList<DomainModel> domains = <DomainModel>[].obs;
  final RxList<DomainModel> filteredDomains = <DomainModel>[].obs;
  final RxList<String> categories = <String>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Search
  final RxString searchQuery = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final subdomainsController = TextEditingController(); // Added
  final Rx<String> selectedCategory = 'Technical'.obs;
  final Rx<String> selectedIcon = 'code'.obs;
  final RxBool isActive = true.obs;

  // Editing domain
  Rx<DomainModel?> editingDomain = Rx<DomainModel?>(null);

  final List<String> defaultCategories = [
    'Technical',
    'Behavioral',
    'Design',
    'Management',
    'Sales',
    'B.Tech (CS/IT)',
    'B.Tech (Mechanical)',
    'B.Tech (EEE)',
    'B.Tech (ECE)',
    'Medical/MBBS',
    'Nursing',
    'Pharmacy',
    'BCA',
    'B.Sc',
    'Reasoning',
    'Other',
  ];

  final Map<String, String> iconOptions = {
    'code': 'Code',
    'psychology': 'Psychology',
    'design_services': 'Design',
    'business': 'Business',
    'trending_up': 'Sales',
    'school': 'Education',
    'science': 'Science',
    'engineering': 'Engineering',
    'account_balance': 'Finance',
    'language': 'Languages',
    'computer': 'Computer',
    'cloud': 'Cloud',
    'phone_android': 'Mobile',
    'work': 'Professional',
    'lightbulb': 'Creative',
    'mobile_friendly': 'Mobile Friendly',
    'terminal': 'Terminal',
    'layers': 'Layers',
    'security': 'Security',
    'settings': 'Settings',
    'bolt': 'Bolt',
    'memory': 'Memory',
    'architecture': 'Architecture',
    'local_hospital': 'Hospital',
    'health_and_safety': 'Health',
    'medical_services': 'Pharmacy',
    'business_center': 'Business Center',
    'laptop_mac': 'Laptop',
    'calculate': 'Calculate',
    'record_voice_over': 'Voice Over',
  };

  @override
  void onInit() {
    super.onInit();
    loadDomains();
    loadCategories();
    
    // Listen to search changes
    debounce(searchQuery, (_) => filterDomains(), time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    subdomainsController.dispose(); // Added
    super.onClose();
  }

  void loadDomains() {
    isLoading.value = true;
    _domainService.getDomainsStream().listen(
      (domainsList) {
        domains.assignAll(domainsList);
        filterDomains();
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar('Connection Issue', 'We are having trouble loading domains. Please check your internet.');
      },
    );
  }

  void loadCategories() async {
    final cats = await _domainService.getCategories();
    categories.value = [...defaultCategories, ...cats].toSet().toList();
  }

  void filterDomains() {
    if (searchQuery.value.isEmpty) {
      filteredDomains.assignAll(domains);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredDomains.assignAll(domains.where((domain) {
        return domain.name.toLowerCase().contains(query) ||
            domain.category.toLowerCase().contains(query) ||
            domain.description.toLowerCase().contains(query);
      }).toList());
    }
  }

  Future<void> seedDefaults() async {
    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> defaults = [
        {
          'name': 'Flutter App Development',
          'iconName': 'mobile_friendly',
          'category': 'B.Tech (CS/IT)',
          'description': 'Advanced cross-platform mobile app development with Dart and Flutter framework.',
          'subdomains': ['State Management', 'Custom UI', 'API Integration', 'Performance'],
        },
        {
          'name': 'React & Frontend',
          'iconName': 'layers',
          'category': 'B.Tech (CS/IT)',
          'description': 'Modern web development using React, Hooks, Redux, and responsive design.',
          'subdomains': ['Hooks', 'Redux', 'JSX', 'Virtual DOM'],
        },
        {
          'name': 'Java Backend Dev',
          'iconName': 'code',
          'category': 'B.Tech (CS/IT)',
          'description': 'Server-side development using Java, Spring Boot, and Microservices architecture.',
          'subdomains': ['Spring Boot', 'Hibernate', 'Microservices', 'Multithreading'],
        },
        {
          'name': 'Python AI & ML',
          'iconName': 'terminal',
          'category': 'B.Tech (CS/IT)',
          'description': 'Data science and machine learning fundamentals using Python and modern libraries.',
          'subdomains': ['NumPy/Pandas', 'Scikit-Learn', 'Deep Learning', 'Data Preprocessing'],
        },
        {
          'name': 'Nursing & Healthcare',
          'iconName': 'local_hospital',
          'category': 'Nursing',
          'description': 'Essential nursing practices, patient care, and medical ethics for healthcare professionals.',
          'subdomains': ['Emergency Care', 'Medication Management', 'Patient Assessment'],
        },
        {
          'name': 'Mechanical Design',
          'iconName': 'engineering',
          'category': 'B.Tech (Mechanical)',
          'description': 'Applied mechanics, thermodynamics, and computer-aided design for mechanical engineers.',
          'subdomains': ['Thermodynamics', 'Machine Design', 'AutoCAD/SolidWorks'],
        },
        {
          'name': 'Digital Marketing',
          'iconName': 'trending_up',
          'category': 'Other',
          'description': 'SEO, SEM, Social Media, and Content Strategy for the modern digital landscape.',
          'subdomains': ['SEO Strategy', 'Content Planning', 'Ad Campaigns', 'Analytics'],
        },
        {
          'name': 'HR Management',
          'iconName': 'psychology',
          'category': 'Other',
          'description': 'Recruitment, employee relations, and organizational development strategies.',
          'subdomains': ['Talent Acquisition', 'Policy Design', 'Conflict Resolution'],
        },
        {
          'name': 'Retail Sales',
          'iconName': 'business_center',
          'category': 'Other',
          'description': 'Customer service, inventory management, and sales techniques for retail environments.',
          'subdomains': ['Customer Service', 'Inventory Control', 'Point of Sale'],
        },
        {
          'name': 'Hospitality & Tourism',
          'iconName': 'business',
          'category': 'Other',
          'description': 'Guest services, hotel management, and travel industry operations.',
          'subdomains': ['Guest Relations', 'Front Desk', 'Event Management'],
        },
        {
          'name': 'Financial Analysis',
          'iconName': 'account_balance',
          'category': 'Other',
          'description': 'Corporate finance, investment banking, and accounting principles.',
          'subdomains': ['Balance Sheets', 'Taxation', 'Corporate Finance'],
        },
        {
          'name': 'UX/UI Design',
          'iconName': 'design_services',
          'category': 'Design',
          'description': 'User research, wireframing, and visual design for digital products.',
          'subdomains': ['Figma', 'User Research', 'Typography'],
        }
      ];

      for (var data in defaults) {
        final domain = DomainModel(
          id: '', // Will be generated
          name: data['name'],
          iconName: data['iconName'],
          category: data['category'],
          description: data['description'],
          subdomains: List<String>.from(data['subdomains']),
          createdAt: DateTime.now(),
        );
        await _domainService.addDomain(domain);
      }

      Get.snackbar('Success', 'Default domains restored successfully!', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green.withOpacity(0.8), 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to seed domains: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startEdit(DomainModel domain) {
    editingDomain.value = domain;
    nameController.text = domain.name;
    descriptionController.text = domain.description;
    subdomainsController.text = domain.subdomains.join(', '); // Added
    selectedCategory.value = domain.category;
    selectedIcon.value = domain.iconName;
    isActive.value = domain.isActive;
  }

  void cancelEdit() {
    editingDomain.value = null;
    clearForm();
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    subdomainsController.clear(); // Added
    selectedCategory.value = 'Technical';
    selectedIcon.value = 'code';
    isActive.value = true;
  }

  Future<void> saveDomain() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Input Required', 'Please provide a name for the domain.');
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Input Required', 'A short description helps users understand the domain.');
      return;
    }

    isSaving.value = true;

    try {
      final subdomains = subdomainsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final domain = DomainModel(
        id: editingDomain.value?.id ?? '',
        name: nameController.text.trim(),
        iconName: selectedIcon.value,
        category: selectedCategory.value,
        description: descriptionController.text.trim(),
        subdomains: subdomains, // Added
        isActive: isActive.value,
        createdAt: editingDomain.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (editingDomain.value != null) {
        // Update existing
        await _domainService.updateDomain(editingDomain.value!.id, domain);
        Get.snackbar(
          'Success!',
          'Domain has been updated.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        // Add new
        await _domainService.addDomain(domain);
        Get.snackbar(
          'Success!',
          'New domain is now live.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

      cancelEdit();
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar(
        'Save Failed',
        'We couldn\'t save the domain right now. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStatus(DomainModel domain) async {
    try {
      await _domainService.toggleDomainStatus(domain.id, !domain.isActive);
      Get.snackbar(
        'Success',
        '${domain.name} ${!domain.isActive ? "activated" : "deactivated"}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle status: $e');
    }
  }

  Future<void> deleteDomain(DomainModel domain) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${domain.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _domainService.deleteDomain(domain.id);
        Get.snackbar(
          'Success',
          'Domain deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete domain: $e');
      }
    }
  }
}
