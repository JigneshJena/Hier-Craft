import 'package:get/get.dart';

class PrepHubController extends GetxController {
  final List<PrepCategory> categories = [
    PrepCategory(
      title: "Behavioral Questions",
      icon: "groups_rounded",
      items: [
        PrepItem(title: "The STAR Method", content: "Situation, Task, Action, Result. Use this to structure your answers."),
        PrepItem(title: "Tell me about yourself", content: "Focus on your professional journey and key achievements."),
        PrepItem(title: "Strengths & Weaknesses", content: "Be honest but focus on growth and self-awareness."),
      ],
    ),
    PrepCategory(
      title: "Interview Tips",
      icon: "lightbulb_rounded",
      items: [
        PrepItem(title: "Research the Company", content: "Know their mission, products, and recent news."),
        PrepItem(title: "Body Language", content: "Maintain eye contact, sit upright, and smile."),
        PrepItem(title: "Ask Questions", content: "Always have 2-3 questions ready for the interviewer."),
      ],
    ),
  ];
}

class PrepCategory {
  final String title;
  final String icon;
  final List<PrepItem> items;
  PrepCategory({required this.title, required this.icon, required this.items});
}

class PrepItem {
  final String title;
  final String content;
  PrepItem({required this.title, required this.content});
}
