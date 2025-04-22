import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';

class QuizService {
  final _supabase = Supabase.instance.client;

  Future<String> saveQuiz({
    required String topic,
    required String difficulty,
    required List<QuizQuestion> questions,
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First, create the quiz entry
      final quizResponse = await _supabase
          .from('quizzes')
          .insert({
            'user_id': user.id,
            'topic': topic,
            'difficulty': difficulty,
            'question_count': questions.length,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final quizId = quizResponse['id'];

      // Then, save all questions
      final questionsData = questions.map((q) => {
            'quiz_id': quizId,
            'question': q.question,
            'options': q.options,
            'correct_answer_index': q.correctAnswerIndex,
            'created_at': DateTime.now().toIso8601String(),
          }).toList();

      await _supabase.from('quiz_questions').insert(questionsData);

      return quizId;
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserQuizzes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('quizzes')
          .select('*, quiz_questions(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  Future<Map<String, dynamic>> getQuizById(String quizId) async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select('*, quiz_questions(*)')
          .eq('id', quizId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch quiz: $e');
    }
  }
} 