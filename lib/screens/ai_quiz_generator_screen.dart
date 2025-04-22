import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/gemini_service.dart';
import '../services/quiz_service.dart';
import '../services/auth_service.dart';

class AiQuizGeneratorScreen extends StatefulWidget {
  const AiQuizGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<AiQuizGeneratorScreen> createState() => _AiQuizGeneratorScreenState();
}

class _AiQuizGeneratorScreenState extends State<AiQuizGeneratorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GeminiService _geminiService = GeminiService();
  final QuizService _quizService = QuizService();
  final AuthService _authService = AuthService();
  
  String _topic = '';
  String _difficulty = 'Advanced';
  int _questionCount = 5;
  bool _isGenerating = false;
  bool _isSaving = false;
  List<QuizQuestion>? _generatedQuestions;
  String? _error;
  
  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];
  
  final List<int> _questionCountOptions = [3, 5, 7, 10];
  
  Future<void> _generateQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      _isGenerating = true;
      _generatedQuestions = null;
      _error = null;
    });
    
    try {
      final questions = await _geminiService.generateQuizQuestions(
        _topic,
        _difficulty,
        _questionCount,
      );
      
      setState(() {
        _generatedQuestions = questions;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating quiz: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQuiz() async {
    if (_generatedQuestions == null) return;

    try {
      setState(() {
        _isSaving = true;
      });

      await _quizService.saveQuiz(
        topic: _topic,
        difficulty: _difficulty,
        questions: _generatedQuestions!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Quiz Generator'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _generatedQuestions != null
            ? _buildGeneratedQuiz()
            : _buildQuizGeneratorForm(),
      ),
    );
  }

  Widget _buildQuizGeneratorForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Custom SQL Quiz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Our AI will generate questions based on your specifications',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Topic',
                      hintText: 'e.g., SQL Joins, Indexes, Normalization',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a topic';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _topic = value ?? '';
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                    ),
                    value: _difficulty,
                    items: _difficulties.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _difficulty = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Number of Questions',
                      border: OutlineInputBorder(),
                    ),
                    value: _questionCount,
                    items: _questionCountOptions.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value questions'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _questionCount = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isGenerating ? null : _generateQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Generating Quiz...'),
                    ],
                  )
                : const Text('Generate Quiz'),
          ),
          if (_isGenerating) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 10),
            const Text(
              'Our AI is creating custom questions based on your topic...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneratedQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quiz on $_topic',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$_difficulty level • $_questionCount questions',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _generatedQuestions = null;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      tooltip: 'Change settings',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _generatedQuestions!.length,
            itemBuilder: (context, index) {
              final question = _generatedQuestions![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text('${index + 1}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        question.options.length,
                        (optionIndex) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: optionIndex,
                                groupValue: question.correctAnswerIndex,
                                onChanged: null,
                              ),
                              Expanded(
                                child: Text(
                                  question.options[optionIndex],
                                  style: TextStyle(
                                    fontWeight: optionIndex == question.correctAnswerIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: optionIndex == question.correctAnswerIndex
                                        ? Colors.green
                                        : null,
                                  ),
                                ),
                              ),
                              if (optionIndex == question.correctAnswerIndex)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Saving Quiz...'),
                    ],
                  )
                : const Text('Save Quiz'),
          ),
        ),
      ],
    );
  }
} 