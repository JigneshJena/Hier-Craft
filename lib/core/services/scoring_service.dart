import 'package:get/get.dart';

class ScoringService extends GetxService {
  
  Map<String, dynamic> evaluateAnswer(String answer, List<Map<String, dynamic>> contextElements) {
    int score = 0;
    String feedback = "";

    String lowerAnswer = answer.toLowerCase();

    for (var element in contextElements) {
      String keyPrompt = element['word'].toString().toLowerCase();
      List<String> variations = List<String>.from(element['synonyms'] ?? []);
      
      bool identified = lowerAnswer.contains(keyPrompt);
      if (!identified) {
        for (var v in variations) {
          if (lowerAnswer.contains(v.toLowerCase())) {
            identified = true;
            break;
          }
        }
      }

      if (identified) {
        score += (element['points'] as num).toInt();
      }
    }

    if (score == 0) {
      feedback = "The answer doesn't seem to address the core concepts of the question. Try to be more specific.";
    } else if (score < 5) {
      feedback = "You've touched on some valid points, but a more detailed explanation would be better.";
    } else if (score < 8) {
      feedback = "Good response! You demonstrate a solid understanding of the topic.";
    } else {
      feedback = "Excellent! Your answer is comprehensive and accurate.";
    }

    return {
      "score": score,
      "feedback": feedback,
    };
  }
}
