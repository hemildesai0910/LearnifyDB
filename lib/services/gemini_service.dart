import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_question.dart';

class GeminiService {
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<List<QuizQuestion>> generateQuizQuestions(String topic, String difficulty, int count) async {
    if (_apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    final prompt = '''
Generate $count SQL quiz questions about $topic at $difficulty level.
Each question should have 4 options with exactly one correct answer.
Format the response as a JSON array with the following structure:
[{
  "question": "question text",
  "options": ["option1", "option2", "option3", "option4"],
  "correctAnswerIndex": 0-3
}]
Ensure questions are challenging and relevant to the topic.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE'
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        final jsonStart = generatedText.indexOf('[');
        final jsonEnd = generatedText.lastIndexOf(']') + 1;
        final jsonString = generatedText.substring(jsonStart, jsonEnd);

        final List<dynamic> questionsJson = jsonDecode(jsonString);

        return questionsJson.map((json) => QuizQuestion(
          question: json['question'],
          options: List<String>.from(json['options']),
          correctAnswerIndex: json['correctAnswerIndex'],
        )).toList();
      } else {
        throw Exception('Failed to generate quiz: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating quiz: $e');
    }
  }
}
