import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ExamProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isExamActive = false;
  String _testTitle = "";
  String _testType = "practice";
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;

  // Selected option per question index: null if unattempted, 0..3 if answered
  final Map<int, int?> _answers = {};
  final Set<int> _flagged = {};

  int _remainingSeconds = 0;
  int _totalDurationSeconds = 0;
  Timer? _countdownTimer;

  int _tabSwitchCount = 0;
  bool _isSubmitting = false;
  TestResultModel? _lastResult;

  // Getters
  bool get isExamActive => _isExamActive;
  String get testTitle => _testTitle;
  String get testType => _testType;
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  int? get currentAnswer => _answers[_currentIndex];
  bool get isCurrentFlagged => _flagged.contains(_currentIndex);

  bool isQuestionAnswered(int index) =>
      _answers.containsKey(index) && _answers[index] != null && _answers[index]! >= 0;

  bool isQuestionFlagged(int index) => _flagged.contains(index);

  int get remainingSeconds => _remainingSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
  int get tabSwitchCount => _tabSwitchCount;
  bool get isSubmitting => _isSubmitting;
  TestResultModel? get lastResult => _lastResult;

  // Stats
  int get answeredCount =>
      _answers.values.where((ans) => ans != null && ans >= 0).length;
  int get flaggedCount => _flagged.length;
  int get unvisitedCount =>
      _questions.length - _answers.keys.length;

  void startExam({
    required String title,
    required String type,
    required int durationMinutes,
    required List<QuestionModel> questionsList,
  }) {
    _countdownTimer?.cancel();
    _isExamActive = true;
    _testTitle = title;
    _testType = type;
    _questions = questionsList;
    _currentIndex = 0;
    _answers.clear();
    _flagged.clear();
    _totalDurationSeconds = durationMinutes * 60;
    _remainingSeconds = _totalDurationSeconds;
    _tabSwitchCount = 0;
    _lastResult = null;
    _isSubmitting = false;

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        submitExam(); // Auto submit when time runs out
      }
    });

    notifyListeners();
  }

  void selectOption(int optionIndex) {
    if (!_isExamActive) return;
    _answers[_currentIndex] = optionIndex;
    notifyListeners();
  }

  void clearAnswer() {
    if (!_isExamActive) return;
    _answers.remove(_currentIndex);
    notifyListeners();
  }

  void toggleFlag() {
    if (!_isExamActive) return;
    if (_flagged.contains(_currentIndex)) {
      _flagged.remove(_currentIndex);
    } else {
      _flagged.add(_currentIndex);
    }
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void recordTabSwitch() {
    if (_isExamActive) {
      _tabSwitchCount++;
      notifyListeners();
    }
  }

  Future<TestResultModel?> submitExam() async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _countdownTimer?.cancel();
    notifyListeners();

    try {
      final answerPayload = <Map<String, dynamic>>[];
      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        answerPayload.add({
          'question_id': q.id,
          'selected_option': _answers[i],
          'time_spent_seconds': 0,
        });
      }

      final timeTaken = _totalDurationSeconds - _remainingSeconds;
      final result = await _api.submitTest(
        testTitle: _testTitle,
        testType: _testType,
        answers: answerPayload,
        totalTimeSeconds: timeTaken > 0 ? timeTaken : 1,
      );

      _lastResult = result;
      _isExamActive = false;
      _isSubmitting = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }

  void resetExam() {
    _countdownTimer?.cancel();
    _isExamActive = false;
    _lastResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
