import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_item.dart';

class NewsService {
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<List<NewsItem>> fetchLatestNews() async {
    if (_apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

final prompt = '''
Act as a tech news reporter.

Generate a JSON array of 5 recent news articles (strictly from the last 30 days — today is April 22, 2025) related to:
- SQL and NoSQL databases
- New updates/releases in Postgres, MySQL, MongoDB, Oracle, SQL Server, etc.
- Innovations or trends in database management systems (DBMS)
- Cloud databases (e.g., AWS RDS, Azure SQL, Google Cloud SQL)

Each item must have:
- "title": Short and clear
- "description": 1-2 line summary of the news
- "source": Trusted blog/news source name
- "date": ISO format (YYYY-MM-DD, recent only)
- "url": (if possible, provide an actual article link)

⚠️ Respond ONLY with a valid JSON array. No markdown, no explanation, no intro or outro text.
''';


    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
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
            'temperature': 0.5,
            'topK': 40,
            'topP': 0.9,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedText =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        // Extract JSON array from the response text
        final jsonStart = generatedText.indexOf('[');
        final jsonEnd = generatedText.lastIndexOf(']') + 1;
        final jsonString = generatedText.substring(jsonStart, jsonEnd);

        final List<dynamic> newsJson = jsonDecode(jsonString);
        return newsJson.map((json) => NewsItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch news: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
