import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._internal();
  factory QuestionRepository() => _instance;
  QuestionRepository._internal();

  final Map<String, List<QuestionModel>> _byTopic = {};
  final List<QuestionModel> _allQuestions = [];
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr);
      int counter = 1;

      rawMap.forEach((topicKey, val) {
        if (val is List) {
          final list = <QuestionModel>[];
          for (final item in val) {
            if (item is Map<String, dynamic>) {
              final q = QuestionModel.fromJson(item, counter++);
              list.add(q);
              _allQuestions.add(q);
            }
          }
          final normalizedKey = _normalizeKey(topicKey);
          _byTopic[normalizedKey] = list;
          // Alias di to data_interp and vice versa
          if (normalizedKey == 'data_interp') _byTopic['di'] = list;
          if (normalizedKey == 'di') _byTopic['data_interp'] = list;
        }
      });
      _isLoaded = true;
    } catch (e) {
      // Fallback built-in pool if rootBundle has an issue
      _populateEmergencyPool();
      _isLoaded = true;
    }
  }

  String _normalizeKey(String key) {
    final lower = key.toLowerCase().trim();
    if (lower.contains('apt')) return 'aptitude';
    if (lower.contains('logic')) return 'logical';
    if (lower.contains('verb') || lower.contains('eng')) return 'verbal';
    if (lower.contains('cod') || lower.contains('dsa') || lower.contains('prog')) return 'coding';
    if (lower.contains('di') || lower.contains('data')) return 'di';
    return lower;
  }

  Future<List<QuestionModel>> getQuestionsForTopic(String topicKey, {int limit = 15}) async {
    await init();
    final norm = _normalizeKey(topicKey);
    final pool = _byTopic[norm] ?? _allQuestions;
    if (pool.isEmpty) return _emergencyQuestions;
    final shuffled = List<QuestionModel>.from(pool)..shuffle();
    return shuffled.take(limit.clamp(1, pool.length)).toList();
  }

  Future<List<QuestionModel>> getCompanyQuestions(String company, {int limit = 20}) async {
    await init();
    if (_allQuestions.isEmpty) return _emergencyQuestions;
    final shuffled = List<QuestionModel>.from(_allQuestions)..shuffle();
    return shuffled.take(limit.clamp(1, _allQuestions.length)).toList();
  }

  Future<List<QuestionModel>> getQuickQuestions(String mode, {int limit = 15}) async {
    await init();
    if (_allQuestions.isEmpty) return _emergencyQuestions;
    final count = mode.toLowerCase().contains('sprint')
        ? 5
        : mode.toLowerCase().contains('speed')
            ? 10
            : limit;
    final shuffled = List<QuestionModel>.from(_allQuestions)..shuffle();
    return shuffled.take(count.clamp(1, _allQuestions.length)).toList();
  }

  void _populateEmergencyPool() {
    _allQuestions.addAll(_emergencyQuestions);
    _byTopic['aptitude'] = _emergencyQuestions.where((q) => q.topic.toLowerCase() == 'aptitude').toList();
    _byTopic['logical'] = _emergencyQuestions.where((q) => q.topic.toLowerCase() == 'logical').toList();
    _byTopic['verbal'] = _emergencyQuestions.where((q) => q.topic.toLowerCase() == 'verbal').toList();
    _byTopic['coding'] = _emergencyQuestions.where((q) => q.topic.toLowerCase() == 'coding').toList();
    _byTopic['di'] = _emergencyQuestions.where((q) => q.topic.toLowerCase() == 'di' || q.topic.toLowerCase() == 'aptitude').toList();
  }

  static final List<QuestionModel> _emergencyQuestions = [
    QuestionModel(
      id: 1,
      topic: 'Aptitude',
      questionText: 'A starts a business with ₹20,000. B joins 3 months later with ₹30,000. What is the profit-sharing ratio at the end of the year?',
      options: ['8:9', '2:3', '4:5', '1:1'],
      correctAnswer: 0,
      concept: 'Partnership',
      difficulty: 'Medium',
      explanation: "A's investment = 20,000 × 12 = 240,000. B's investment = 30,000 × 9 = 270,000. Ratio = 240:270 = 8:9.",
      tags: ['aptitude', 'partnership'],
    ),
    QuestionModel(
      id: 2,
      topic: 'Logical',
      questionText: 'If in a certain code, MONKEY is written as XDJMNL, how is TIGER written in that code?',
      options: ['QDFHS', 'SDFHQ', 'UJHFS', 'SHFDQ'],
      correctAnswer: 0,
      concept: 'Coding-Decoding',
      difficulty: 'Medium',
      explanation: 'Each letter is shifted back by 1 and the order is reversed.',
      tags: ['logical', 'coding'],
    ),
    QuestionModel(
      id: 3,
      topic: 'Verbal',
      questionText: 'Choose the word that is most nearly opposite in meaning to CANDID:',
      options: ['Deceptive', 'Frank', 'Honest', 'Sincere'],
      correctAnswer: 0,
      concept: 'Antonyms',
      difficulty: 'Easy',
      explanation: 'Candid means truthful; deceptive means misleading.',
      tags: ['verbal', 'vocabulary'],
    ),
    QuestionModel(
      id: 4,
      topic: 'Coding',
      questionText: 'What is the time complexity of searching an element in a balanced BST?',
      options: ['O(log n)', 'O(n)', 'O(1)', 'O(n log n)'],
      correctAnswer: 0,
      concept: 'Data Structures',
      difficulty: 'Easy',
      explanation: 'A balanced BST eliminates half the remaining nodes with each step.',
      tags: ['coding', 'trees'],
    ),
    QuestionModel(
      id: 5,
      topic: 'Aptitude',
      questionText: 'A train running at 60 km/hr crosses a pole in 9 seconds. What is the length of the train?',
      options: ['150 metres', '120 metres', '180 metres', '324 metres'],
      correctAnswer: 0,
      concept: 'Time and Distance',
      difficulty: 'Easy',
      explanation: 'Speed = 60 × (5/18) = 50/3 m/sec. Length = 50/3 × 9 = 150m.',
      tags: ['aptitude', 'trains'],
    ),
  ];
}
