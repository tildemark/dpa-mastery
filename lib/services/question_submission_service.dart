import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for user-submitted community questions.
class QuestionSubmission {
  final String authorName;
  final String authorEmail;
  final int difficultyLevel;
  final List<String> tags;
  final String lessonConcept;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuestionSubmission({
    required this.authorName,
    required this.authorEmail,
    required this.difficultyLevel,
    required this.tags,
    required this.lessonConcept,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'author_name': authorName,
        'author_email': authorEmail,
        'difficulty_level': difficultyLevel,
        'tags': tags,
        'lesson_concept': lessonConcept,
        'question_text': questionText,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      };
}

/// Service to submit user-authored questions for community review / inclusion.
class QuestionSubmissionService {
  QuestionSubmissionService({String? endpointUrl})
      : _endpointUrl = endpointUrl ??
            'https://api.github.com/repos/tildeapp/dpa-mastery/issues';

  final String _endpointUrl;

  /// Submits a question as a formatted GitHub Issue for review.
  Future<bool> submitQuestion(
    QuestionSubmission submission, {
    String? githubToken,
  }) async {
    try {
      final title = '[Community Question] L${submission.difficultyLevel}: ${submission.tags.firstOrNull ?? "General"}';
      final body = '''
### 📝 Community Question Submission

**Author:** ${submission.authorName} (${submission.authorEmail})
**Difficulty Level:** ${submission.difficultyLevel}
**Tags:** ${submission.tags.join(', ')}

---

#### 💡 Lesson Concept
${submission.lessonConcept}

#### ❓ Question
${submission.questionText}

#### 🔠 Options
${submission.options.asMap().entries.map((e) => '- **${String.fromCharCode(65 + e.key)}:** ${e.value}').join('\n')}

**Correct Answer:** ${submission.correctAnswer}

#### 📖 Explanation
${submission.explanation}

---
```json
${const JsonEncoder.withIndent('  ').convert(submission.toJson())}
```
''';

      final headers = {
        'Content-Type': 'application/json',
        if (githubToken != null) 'Authorization': 'token $githubToken',
      };

      final response = await http.post(
        Uri.parse(_endpointUrl),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'body': body,
          'labels': ['community-submission', 'level-${submission.difficultyLevel}'],
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
