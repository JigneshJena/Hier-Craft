import 'package:get/get.dart';
import '../../data/models/domain_model.dart';
import '../../data/services/domain_service.dart';

class DomainSelectionController extends GetxController {
  final DomainService _domainService = Get.put(DomainService());
  
  final RxList<DomainModel> domains = <DomainModel>[].obs;
  final RxList<DomainModel> filteredDomains = <DomainModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToDomains();
  }

  void _listenToDomains() {
    isLoading.value = true;
    
    // Load sample data immediately to prevent blank screen
    print('📦 Loading sample domains immediately...');
    domains.assignAll(_getSampleDomains());
    _extractCategories();
    _applyFilters();
    isLoading.value = false;
    
    // Then try to listen to Firebase in background
    // If Firebase has data, it will replace the sample data
    _domainService.getActiveDomainsStream().listen(
      (domainList) {
        print('📥 Firebase returned ${domainList.length} domains');
        
        if (domainList.isNotEmpty) {
          print('✅ Replacing sample data with Firebase data');
          domains.assignAll(domainList);
          _extractCategories();
          _applyFilters();
        }
      },
      onError: (error) {
        print('❌ Firebase error (sample data already loaded): $error');
      },
    );
  }

  List<DomainModel> _getSampleDomains() {
    return [
      DomainModel(
        id: 'sample_1',
        name: 'Flutter Development',
        category: 'Engineering',
        description: 'Mobile app development with Flutter framework',
        iconName: 'mobile_friendly',
        subdomains: ['Widgets', 'State Management', 'Firebase'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DomainModel(
        id: 'sample_2',
        name: 'Java Programming',
        category: 'Engineering',
        description: 'Core Java and Spring Boot development',
        iconName: 'code',
        subdomains: ['Core Java', 'Spring Boot', 'Microservices'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DomainModel(
        id: 'sample_3',
        name: 'Python Development',
        category: 'Engineering',
        description: 'Python programming and frameworks',
        iconName: 'terminal',
        subdomains: ['Django', 'Flask', 'Data Science'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DomainModel(
        id: 'sample_4',
        name: 'Data Science',
        category: 'Analytics',
        description: 'Machine Learning and AI',
        iconName: 'analytics',
        subdomains: ['ML', 'Deep Learning', 'Data Analysis'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DomainModel(
        id: 'sample_5',
        name: 'Web Development',
        category: 'Engineering',
        description: 'Full stack web development',
        iconName: 'layers',
        subdomains: ['React', 'Node.js', 'Next.js'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _extractCategories() {
    final Set<String> allCats = {'All'};
    for (var d in domains) {
      allCats.add(d.category);
    }
    categories.assignAll(allCats.toList()..sort((a, b) => a == 'All' ? -1 : a.compareTo(b)));
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
    
    // Filter by Search Query (improved)
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((d) {
        final name = d.name.toLowerCase();
        final category = d.category.toLowerCase();
        final description = (d.description).toLowerCase();
        
        // Match if query is found in name, category, or description
        return name.contains(q) || 
               category.contains(q) ||
               description.contains(q);
      }).toList();
    }
    
    filteredDomains.assignAll(list);
  }
}
