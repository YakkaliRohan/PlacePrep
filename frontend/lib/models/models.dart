class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String college;
  final String degree;
  final String graduationYear;
  final String avatar;
  final bool isGuest;
  final int testsTaken;
  final int questionsSolved;
  final int streak;
  final double totalAccuracy;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.college = "",
    this.degree = "",
    this.graduationYear = "",
    this.avatar = "avatar-default",
    this.isGuest = false,
    this.testsTaken = 0,
    this.questionsSolved = 0,
    this.streak = 0,
    this.totalAccuracy = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      college: json['college'] ?? '',
      degree: json['degree'] ?? '',
      graduationYear: json['graduation_year'] ?? '',
      avatar: json['avatar'] ?? 'avatar-default',
      isGuest: json['is_guest'] ?? false,
      testsTaken: json['tests_taken'] ?? 0,
      questionsSolved: json['questions_solved'] ?? 0,
      streak: json['streak'] ?? 0,
      totalAccuracy: (json['total_accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class QuestionModel {
  final int id;
  final String topic;
  final String questionText;
  final List<String> options;
  final int? correctAnswer;
  final String? explanation;
  final String concept;
  final String difficulty;
  final List<String> tags;

  QuestionModel({
    required this.id,
    required this.topic,
    required this.questionText,
    required this.options,
    this.correctAnswer,
    this.explanation,
    required this.concept,
    required this.difficulty,
    required this.tags,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      topic: json['topic'] ?? '',
      questionText: json['question_text'] ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      concept: json['concept'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class DetailedAnswerModel {
  final int questionId;
  final String questionText;
  final List<String> options;
  final int? selectedOption;
  final int correctAnswer;
  final bool isCorrect;
  final String explanation;
  final String concept;
  final String difficulty;

  DetailedAnswerModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    this.selectedOption,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    required this.concept,
    required this.difficulty,
  });

  factory DetailedAnswerModel.fromJson(Map<String, dynamic> json) {
    return DetailedAnswerModel(
      questionId: json['question_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      selectedOption: json['selected_option'],
      correctAnswer: json['correct_answer'] ?? 0,
      isCorrect: json['is_correct'] ?? false,
      explanation: json['explanation'] ?? '',
      concept: json['concept'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }
}

class TestResultModel {
  final int attemptId;
  final String testTitle;
  final String testType;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final double score;
  final double accuracy;
  final int timeTakenSeconds;
  final Map<String, dynamic> sectionBreakdown;
  final List<DetailedAnswerModel> answersSummary;

  TestResultModel({
    required this.attemptId,
    required this.testTitle,
    required this.testType,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
    required this.score,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.sectionBreakdown,
    required this.answersSummary,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      attemptId: json['attempt_id'] ?? 0,
      testTitle: json['test_title'] ?? '',
      testType: json['test_type'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      correctCount: json['correct_count'] ?? 0,
      incorrectCount: json['incorrect_count'] ?? 0,
      unattemptedCount: json['unattempted_count'] ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: json['time_taken_seconds'] ?? 0,
      sectionBreakdown: json['section_breakdown'] ?? {},
      answersSummary: (json['answers_summary'] as List?)
              ?.map((e) => DetailedAnswerModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LeaderboardUserModel {
  final int rank;
  final int userId;
  final String name;
  final String avatar;
  final int testsTaken;
  final int questionsSolved;
  final int streak;
  final double accuracy;

  LeaderboardUserModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.testsTaken,
    required this.questionsSolved,
    required this.streak,
    required this.accuracy,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? 'avatar-default',
      testsTaken: json['tests_taken'] ?? 0,
      questionsSolved: json['questions_solved'] ?? 0,
      streak: json['streak'] ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
