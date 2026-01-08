import 'package:get/get.dart';
import '../../data/models/question_model.dart';

class DomainSelectionController extends GetxController {
  final RxList<InterviewDomain> domains = <InterviewDomain>[].obs;
  final RxList<InterviewDomain> filteredDomains = <InterviewDomain>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDomains();
    _extractCategories();
  }

  void _extractCategories() {
    final Set<String> allCats = {'All'};
    for (var d in domains) {
      allCats.add(d.category);
    }
    categories.assignAll(allCats.toList()..sort((a, b) => a == 'All' ? -1 : a.compareTo(b)));
  }

  void _loadDomains() {
    final List<InterviewDomain> items = [
      // B.Tech / CS
      InterviewDomain(name: "Flutter", icon: "mobile_friendly", subdomains: ["Widgets", "State Management"], category: "B.Tech (CS/IT)"),
      InterviewDomain(name: "Java", icon: "code", subdomains: ["Core Java", "Spring Boot"], category: "B.Tech (CS/IT)"),
      InterviewDomain(name: "Python", icon: "terminal", subdomains: ["Django", "Flask"], category: "B.Tech (CS/IT)"),
      InterviewDomain(name: "Full Stack", icon: "layers", subdomains: ["MERN", "Next.js"], category: "B.Tech (CS/IT)"),
      InterviewDomain(name: "Cybersecurity", icon: "security", subdomains: ["Networking"], category: "B.Tech (CS/IT)"),
      
      // B.Tech / Core Engineering
      InterviewDomain(name: "Mechanical", icon: "settings", subdomains: ["Thermodynamics"], category: "B.Tech (Mechanical)"),
      InterviewDomain(name: "Electrical", icon: "bolt", subdomains: ["Power Systems"], category: "B.Tech (EEE)"),
      InterviewDomain(name: "Electronics/ECE", icon: "memory", subdomains: ["Embedded Systems"], category: "B.Tech (ECE)"),
      InterviewDomain(name: "Civil", icon: "architecture", subdomains: ["Structural"], category: "B.Tech (Civil)"),

      // Medical
      InterviewDomain(name: "MBBS", icon: "local_hospital", subdomains: ["Anatomy", "Medicine"], category: "Medical/MBBS"),
      InterviewDomain(name: "Nursing", icon: "health_and_safety", subdomains: ["Patient Care"], category: "Nursing"),
      InterviewDomain(name: "Pharmacy", icon: "medical_services", subdomains: ["Pharmacology"], category: "Pharmacy"),

      // Business & Others
      InterviewDomain(name: "MBA/Management", icon: "business_center", subdomains: ["Marketing", "HR"], category: "Management"),
      InterviewDomain(name: "BCA", icon: "laptop_mac", subdomains: ["Web Tech", "OOPS"], category: "BCA"),
      InterviewDomain(name: "B.Sc (Science)", icon: "science", subdomains: ["Physics", "Chem"], category: "B.Sc"),

      // Reasoning Questions (as requested)
      InterviewDomain(name: "Logical Reasoning", icon: "psychology", subdomains: ["Aptitude", "Logic"], category: "Reasoning"),
      InterviewDomain(name: "Quantitative Apti", icon: "calculate", subdomains: ["Math", "DI"], category: "Reasoning"),
      InterviewDomain(name: "Verbal Ability", icon: "record_voice_over", subdomains: ["Grammar", "Comprehension"], category: "Reasoning"),
    ];

    domains.assignAll(items);
    filteredDomains.assignAll(items);
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void filterDomains(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var list = domains.toList();
    
    // Filter by Category
    if (selectedCategory.value != 'All') {
      list = list.where((d) => d.category == selectedCategory.value).toList();
    }
    
    // Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((d) => 
        d.name.toLowerCase().contains(q) || 
        d.category.toLowerCase().contains(q)
      ).toList();
    }
    
    filteredDomains.assignAll(list);
  }

}
