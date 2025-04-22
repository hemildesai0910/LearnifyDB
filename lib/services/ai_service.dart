import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // Google Gemini API endpoint - Correct format for Gemini API
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  Future<String> getResponse(String prompt) async {
    try {
      // Get API key from environment variables
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      
      if (apiKey.isEmpty) {
        print('Gemini API key not found in .env file');
        return "Sorry, I'm unable to answer as my API connection is not configured. Please add a valid Gemini API key to the .env file.";
      }
      
      try {
        // Prepare the request with the correct format for Gemini API
        final response = await http.post(
          Uri.parse('$apiUrl?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'contents': [
              {
                'parts': [
                  {
                    'text': 'You are an expert SQL assistant. Provide helpful, accurate, and concise responses to SQL and database questions. Include code examples where appropriate. The user asks: $prompt'
                  }
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 500,
              'topP': 0.95,
              'topK': 40
            }
          }),
        ).timeout(Duration(seconds: 15));
        
        print('Gemini API Status Code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Parse Gemini API response format
          try {
            if (data['candidates'] != null && 
                data['candidates'].isNotEmpty && 
                data['candidates'][0]['content'] != null &&
                data['candidates'][0]['content']['parts'] != null &&
                data['candidates'][0]['content']['parts'].isNotEmpty) {
              
              return data['candidates'][0]['content']['parts'][0]['text'];
            } else {
              print('Unexpected Gemini API response format: $data');
              return _generateDynamicResponse(prompt);
            }
          } catch (e) {
            print('Error parsing Gemini API response: $e');
            print('Response data: $data');
            return _generateDynamicResponse(prompt);
          }
        } else {
          print('Gemini API Error: ${response.statusCode} - ${response.body}');
          // Try alternative API endpoint if first one fails
          return await _tryAlternativeAPI(prompt, apiKey);
        }
      } catch (e) {
        print('Gemini API call failed: $e');
        return _generateDynamicResponse(prompt);
      }
    } catch (e) {
      print('Error communicating with AI service: $e');
      return _generateDynamicResponse(prompt);
    }
  }
  
  // Try an alternative Gemini API endpoint
  Future<String> _tryAlternativeAPI(String prompt, String apiKey) async {
    try {
      // Try a different model or endpoint
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are an expert SQL assistant. Answer this SQL question concisely: $prompt'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500
          }
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        try {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } catch (e) {
          print('Error parsing alternative API response: $e');
          return _generateDynamicResponse(prompt);
        }
      } else {
        print('Alternative API also failed: ${response.statusCode} - ${response.body}');
        return _generateDynamicResponse(prompt);
      }
    } catch (e) {
      print('Alternative API error: $e');
      return _generateDynamicResponse(prompt);
    }
  }
  
  // Generate a dynamic response based on the query content
  String _generateDynamicResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase().trim();
    
    // Extract keywords from the prompt
    final List<String> keywords = lowerPrompt
        .replaceAll('?', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .split(' ')
        .where((word) => word.length > 3)  // Only consider meaningful words
        .toList();
    
    // Identify SQL concepts in the query
    final Map<String, int> conceptScores = {};
    
    // SQL concepts to detect
    final Map<String, List<String>> sqlConcepts = {
      'select': ['select', 'query', 'retrieve', 'get', 'fetch', 'data'],
      'join': ['join', 'combine', 'tables', 'relationship'],
      'where': ['where', 'filter', 'condition', 'criteria'],
      'create': ['create', 'make', 'table', 'structure', 'schema'],
      'index': ['index', 'performance', 'speed', 'optimize'],
      'group': ['group', 'aggregate', 'summarize', 'count', 'sum'],
      'transaction': ['transaction', 'commit', 'rollback', 'acid'],
      'key': ['key', 'primary', 'foreign', 'unique', 'constraint'],
      'normalization': ['normal', 'form', 'redundancy', 'design'],
      'function': ['function', 'procedure', 'stored', 'trigger'],
      'database': ['database', 'schema', 'structure', 'rdbms'],
      'comparison': ['comparison', 'nosql', 'relational', 'difference'],
    };
    
    // Score each concept based on keyword matches
    sqlConcepts.forEach((concept, relatedTerms) {
      int score = 0;
      
      // Check if the concept name itself is in the prompt
      if (lowerPrompt.contains(concept)) {
        score += 5;
      }
      
      // Check for related terms
      for (final term in relatedTerms) {
        if (lowerPrompt.contains(term)) {
          score += 2;
        }
      }
      
      // Check individual words
      for (final keyword in keywords) {
        if (relatedTerms.contains(keyword)) {
          score += 1;
        }
      }
      
      if (score > 0) {
        conceptScores[concept] = score;
      }
    });
    
    // Find the highest scoring concept
    String topConcept = 'general';
    int maxScore = 0;
    
    conceptScores.forEach((concept, score) {
      if (score > maxScore) {
        maxScore = score;
        topConcept = concept;
      }
    });
    
    // Generate specific response based on detected concept
    switch (topConcept) {
      case 'select':
        return "Based on your question about ${_extractSubject(prompt)}, here's how you can use SELECT statements:\n\n```sql\nSELECT column1, column2, ...\nFROM table_name\nWHERE condition;\n```\n\nFor example, if you want to get ${_extractExample(prompt)}:\n```sql\nSELECT name, price \nFROM products \nWHERE category = 'Electronics';\n```\n\nYou can also use wildcards with SELECT * to get all columns.";
        
      case 'join':
        return "For your question about joining ${_extractSubject(prompt)}, SQL JOIN operations combine rows from different tables:\n\n```sql\nSELECT orders.order_id, customers.name\nFROM orders\nINNER JOIN customers ON orders.customer_id = customers.id\n```\n\nThis creates a combined result with matched rows from both tables. Other types include LEFT JOIN (all rows from left table), RIGHT JOIN, and FULL JOIN.";
        
      case 'where':
        return "Regarding filtering ${_extractSubject(prompt)}, the WHERE clause is used to filter records:\n\n```sql\nSELECT * FROM employees\nWHERE department = 'Marketing' AND salary > 50000;\n```\n\nYou can use multiple conditions with AND/OR operators, comparison operators (<, >, <=, >=, =, !=), and special operators like BETWEEN, IN, LIKE, and IS NULL.";
        
      case 'create':
        return "To create a ${_extractSubject(prompt)} table, you can use:\n\n```sql\nCREATE TABLE users (\n  id INT PRIMARY KEY,\n  username VARCHAR(50) NOT NULL,\n  email VARCHAR(100) UNIQUE,\n  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP\n);\n```\n\nYou can specify column data types, constraints (NOT NULL, UNIQUE, PRIMARY KEY), and default values.";
        
      case 'index':
        return "For improving performance of ${_extractSubject(prompt)}, indexes are essential:\n\n```sql\nCREATE INDEX idx_lastname ON customers(last_name);\n```\n\nThis creates an index on the last_name column of the customers table. Indexes speed up SELECT queries but can slow down data modification (INSERT, UPDATE, DELETE).";
        
      case 'database':
        return "A database is an organized collection of structured information or data, typically stored electronically in a computer system. For relational databases, the structure is organized into tables with rows and columns.\n\nCommon SQL database management systems include:\n- MySQL\n- PostgreSQL\n- Microsoft SQL Server\n- Oracle Database\n- SQLite\n\nEach implements the SQL language with some variations and extensions.";
        
      default:
        // Check if it's a general greeting
        if (lowerPrompt.contains("hi") || lowerPrompt.contains("hello") || lowerPrompt.contains("hey") || lowerPrompt.length < 5) {
          return "Hi there! I'm your SQL assistant. How can I help you with your SQL questions today? You can ask about queries, database design, optimization, or any other SQL-related topic.";
        }
        
        // Create a more dynamic general response
        return "I understand you're asking about ${_extractSubject(prompt)}. Here's what I can tell you about SQL:\n\nSQL (Structured Query Language) is used to manage and query relational databases. You can:\n\n- Query data with SELECT statements\n- Filter with WHERE conditions\n- Join tables with JOIN operations\n- Group and aggregate data\n- Create and modify database structures\n\nCould you provide more specific details about what aspect of ${_extractSubject(prompt)} you'd like to know?";
    }
  }
  
  // Helper to extract the main subject from a query
  String _extractSubject(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    // Look for specific patterns like "How do I..." or "What is..."
    if (lowerPrompt.contains("how do i")) {
      final startIndex = lowerPrompt.indexOf("how do i") + 8;
      final endIndex = prompt.indexOf("?", startIndex);
      if (endIndex > startIndex) {
        return prompt.substring(startIndex, endIndex).trim();
      }
    }
    
    if (lowerPrompt.contains("what is")) {
      final startIndex = lowerPrompt.indexOf("what is") + 7;
      final endIndex = prompt.indexOf("?", startIndex);
      if (endIndex > startIndex) {
        return prompt.substring(startIndex, endIndex).trim();
      }
    }
    
    // Default - take the main part of the query
    final words = prompt.split(' ');
    if (words.length > 5) {
      return words.sublist(0, 5).join(' ') + "...";
    } else {
      return prompt;
    }
  }
  
  // Helper to create relevant examples
  String _extractExample(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains("customer")) {
      return "customer information such as name and email";
    } else if (lowerPrompt.contains("product")) {
      return "products with prices over \$100";
    } else if (lowerPrompt.contains("order")) {
      return "orders placed in the last month";
    } else if (lowerPrompt.contains("employee")) {
      return "employees in the IT department";
    } else {
      return "specific records from your database";
    }
  }
} 