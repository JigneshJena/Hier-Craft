import 'package:get/get.dart';
import '../../data/models/question_model.dart';

class DomainSelectionController extends GetxController {
  final RxList<InterviewDomain> domains = <InterviewDomain>[].obs;
  final RxList<InterviewDomain> filteredDomains = <InterviewDomain>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDomains();
  }

  void _loadDomains() {
    // 25-30 domains as per requirements
    final List<InterviewDomain> items = [
      // CS & IT
      InterviewDomain(name: "Flutter", icon: "mobile_friendly", subdomains: ["Widgets", "State Management", "Animations"]),
      InterviewDomain(name: "Java", icon: "code", subdomains: ["Core Java", "Spring Boot", "Hibernate"]),
      InterviewDomain(name: "Python", icon: "terminal", subdomains: ["Django", "Flask", "Pandas"]),
      InterviewDomain(name: "Full Stack", icon: "layers", subdomains: ["MERN", "MEAN", "Next.js"]),
      InterviewDomain(name: "Data Science", icon: "analytics", subdomains: ["ML", "DL", "NLP"]),
      InterviewDomain(name: "DevOps", icon: "cloud", subdomains: ["Docker", "K8s", "CI/CD"]),
      InterviewDomain(name: "Cybersecurity", icon: "security", subdomains: ["Pentesting", "Networking"]),
      InterviewDomain(name: "UI/UX Design", icon: "palette", subdomains: ["Figma", "User Research"]),
      
      // Engineering
      InterviewDomain(name: "Mechanical", icon: "settings", subdomains: ["Thermodynamics", "CAD/CAM"]),
      InterviewDomain(name: "Electrical", icon: "bolt", subdomains: ["Power Systems", "Machines"]),
      InterviewDomain(name: "Electronics/ECE", icon: "memory", subdomains: ["Embedded", "VLSI"]),
      InterviewDomain(name: "Civil", icon: "architecture", subdomains: ["Structural", "Construction"]),
      InterviewDomain(name: "Chemical", icon: "science", subdomains: ["Process Control", "Thermodynamics"]),
      InterviewDomain(name: "Aerospace", icon: "flight", subdomains: ["Aerodynamics", "Propulsion"]),
      InterviewDomain(name: "Automobile", icon: "directions_car", subdomains: ["Vehicle Dynamics", "Engines"]),

      // Medical
      InterviewDomain(name: "Pharmacy", icon: "medical_services", subdomains: ["Pharmacology", "Drug Dev"]),
      InterviewDomain(name: "MBBS", icon: "local_hospital", subdomains: ["Anatomy", "Medicine"]),
      InterviewDomain(name: "Nursing", icon: "health_and_safety", subdomains: ["Patient Care", "Procedures"]),

      // Business
      InterviewDomain(name: "Management/MBA", icon: "business_center", subdomains: ["Marketing", "Finance", "HR"]),
      InterviewDomain(name: "Digital Marketing", icon: "campaign", subdomains: ["SEO", "Social Media"]),
      InterviewDomain(name: "Human Resources", icon: "groups", subdomains: ["Recruitment", "Relations"]),
      InterviewDomain(name: "Finance", icon: "account_balance", subdomains: ["Accounting", "Investment"]),

      // Others
      InterviewDomain(name: "Law/LLB", icon: "gavel", subdomains: ["Corporate", "Criminal"]),
      InterviewDomain(name: "Architecture", icon: "home_work", subdomains: ["Building Design", "Urban"]),
      InterviewDomain(name: "Hospitality", icon: "hotel", subdomains: ["Hotel Mngt", "Events"]),
      InterviewDomain(name: "DSA", icon: "schema", subdomains: ["Arrays", "Graphs", "DP"]),
      InterviewDomain(name: "DBMS", icon: "storage", subdomains: ["SQL", "NoSQL"]),
    ];

    domains.assignAll(items);
    filteredDomains.assignAll(items);
  }

  void filterDomains(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredDomains.assignAll(domains);
    } else {
      filteredDomains.assignAll(
        domains.where((d) => d.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

}
