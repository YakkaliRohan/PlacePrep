import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/models.dart';
import 'question_repository.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String baseUrl = AppConstants.defaultApiUrl;
  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Auth APIs ---
  Future<UserModel> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      await setToken(data['access_token']);
      return UserModel.fromJson(data['user']);
    } else {
      final err = jsonDecode(res.body);
      throw Exception(err['detail'] ?? 'Signup failed');
    }
  }

  Future<UserModel> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await setToken(data['access_token']);
      return UserModel.fromJson(data['user']);
    } else {
      final err = jsonDecode(res.body);
      throw Exception(err['detail'] ?? 'Invalid email or password');
    }
  }

  Future<UserModel> guestLogin([String name = "Guest Explorer"]) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/guest'),
      headers: _headers(),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await setToken(data['access_token']);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Guest login failed');
    }
  }

  Future<UserModel?> getMe() async {
    if (_token == null) return null;
    try {
      final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers());
      if (res.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    await setToken(null);
  }

  // --- Questions & Tests APIs ---
  Future<List<Map<String, dynamic>>> getTopics() async {
    final res = await http.get(Uri.parse('$baseUrl/questions/topics'), headers: _headers());
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    throw Exception('Failed to load topics');
  }

  Future<List<QuestionModel>> getTopicQuestions(
    String topic, {
    String? difficulty,
    String? concept,
    int limit = 15,
  }) async {
    var url = '$baseUrl/questions/topic/$topic?limit=$limit';
    if (difficulty != null && difficulty.isNotEmpty) url += '&difficulty=$difficulty';
    if (concept != null && concept.isNotEmpty) url += '&concept=$concept';

    try {
      final res = await http.get(Uri.parse(url), headers: _headers());
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          return list.map((e) => QuestionModel.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return await QuestionRepository().getQuestionsForTopic(topic, limit: limit);
  }

  Future<Map<String, dynamic>> getCompanyTest(String company) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/questions/company/$company'), headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List qList = data['questions'] ?? [];
        if (qList.isNotEmpty) {
          return {
            'company': data['company'],
            'time_minutes': data['time_minutes'],
            'total_questions': data['total_questions'],
            'questions': qList.map((e) => QuestionModel.fromJson(e)).toList(),
          };
        }
      }
    } catch (_) {}
    final questions = await QuestionRepository().getCompanyQuestions(company, limit: 20);
    return {
      'company': company,
      'time_minutes': 30,
      'total_questions': questions.length,
      'questions': questions,
    };
  }

  Future<Map<String, dynamic>> getQuickTest(String mode) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/questions/quick-test/$mode'), headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List qList = data['questions'] ?? [];
        if (qList.isNotEmpty) {
          return {
            'mode': data['mode'],
            'title': data['title'],
            'time_minutes': data['time_minutes'],
            'total_questions': data['total_questions'],
            'questions': qList.map((e) => QuestionModel.fromJson(e)).toList(),
          };
        }
      }
    } catch (_) {}
    final questions = await QuestionRepository().getQuickQuestions(mode, limit: 15);
    final isSprint = mode.toLowerCase().contains('sprint');
    final isSpeed = mode.toLowerCase().contains('speed');
    return {
      'mode': mode,
      'title': isSprint ? 'Speed Sprint' : (isSpeed ? 'Standard Drill' : 'Comprehensive Drill'),
      'time_minutes': isSprint ? 5 : (isSpeed ? 10 : 20),
      'total_questions': questions.length,
      'questions': questions,
    };
  }

  Future<TestResultModel> submitTest({
    required String testTitle,
    required String testType,
    required List<Map<String, dynamic>> answers,
    required int totalTimeSeconds,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tests/submit'),
      headers: _headers(),
      body: jsonEncode({
        'test_title': testTitle,
        'test_type': testType,
        'answers': answers,
        'total_time_seconds': totalTimeSeconds,
      }),
    );
    if (res.statusCode == 200) {
      return TestResultModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Test submission failed: ${res.body}');
  }

  // --- Leaderboard & Admin APIs ---
  Future<Map<String, dynamic>> getLeaderboard() async {
    final res = await http.get(Uri.parse('$baseUrl/leaderboard'), headers: _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List top = data['top_performers'] ?? [];
      return {
        'total_participants': data['total_participants'] ?? 0,
        'top_performers': top.map((e) => LeaderboardUserModel.fromJson(e)).toList(),
        'user_rank': data['user_rank'] != null ? LeaderboardUserModel.fromJson(data['user_rank']) : null,
      };
    }
    throw Exception('Failed to load leaderboard');
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/stats'), headers: _headers());
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception('Failed to load admin stats');
  }

  Future<void> submitFeedback(String message, {int rating = 5, String category = "general"}) async {
    await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: _headers(),
      body: jsonEncode({'message': message, 'rating': rating, 'category': category}),
    );
  }
}
