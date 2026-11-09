import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import '../widgets/animated_charts.dart';
import '../widgets/hover_card.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onStartExam;
  final VoidCallback onBackToLanding;

  const DashboardView({
    super.key,
    required this.onStartExam,
    required this.onBackToLanding,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedNavIndex = 0;
  final ApiService _api = ApiService();

  static final List<Map<String, dynamic>> _defaultTopics = [
    {
      'key': 'aptitude',
      'name': 'Quantitative Aptitude',
      'icon': '🧮',
      'question_count': 200,
      'desc': 'Numbers, Profit & Loss, Time & Work, Speed & Distance, Partnerships',
    },
    {
      'key': 'logical',
      'name': 'Logical Reasoning',
      'icon': '🧩',
      'question_count': 116,
      'desc': 'Puzzles, Syllogisms, Blood Relations, Coding-Decoding, Seating',
    },
    {
      'key': 'verbal',
      'name': 'Verbal Ability',
      'icon': '📝',
      'question_count': 110,
      'desc': 'Reading Comprehension, Sentence Correction, Synonyms, Grammar',
    },
    {
      'key': 'coding',
      'name': 'Programming & DSA',
      'icon': '💻',
      'question_count': 80,
      'desc': 'Data Structures, Algorithms, Pseudo-code, OOPs Concepts',
    },
    {
      'key': 'di',
      'name': 'Data Interpretation',
      'icon': '📊',
      'question_count': 65,
      'desc': 'Tables, Bar Graphs, Pie Charts, Caselets, Trend Analysis',
    },
  ];

  List<Map<String, dynamic>> _topics = _defaultTopics;
  bool _isLoadingTopics = false;

  Map<String, dynamic>? _leaderboardData;
  bool _isLoadingLeaderboard = false;

  Map<String, dynamic>? _adminStats;
  bool _isLoadingAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await _api.getTopics();
      if (mounted && topics.isNotEmpty) {
        setState(() {
          _topics = topics;
          _isLoadingTopics = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _topics = _defaultTopics;
          _isLoadingTopics = false;
        });
      }
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoadingLeaderboard = true);
    try {
      final data = await _api.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboardData = data;
          _isLoadingLeaderboard = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLeaderboard = false);
    }
  }

  Future<void> _loadAdminStats() async {
    setState(() => _isLoadingAdmin = true);
    try {
      final data = await _api.getAdminStats();
      if (mounted) {
        setState(() {
          _adminStats = data;
          _isLoadingAdmin = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAdmin = false);
    }
  }

  void _startTopicPractice(String topicKey, String topicName) async {
    final exam = context.read<ExamProvider>();
    try {
      final questions = await _api.getTopicQuestions(topicKey, limit: 15);
      exam.startExam(
        title: '$topicName Practice',
        type: 'practice',
        durationMinutes: 15,
        questionsList: questions,
      );
      widget.onStartExam();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start test: $e')),
        );
      }
    }
  }

    List<QuestionModel> _getMockQuestions(String topic) {
    return [
      QuestionModel(
        id: 1,
        questionText: 'A starts a business with ₹20,000. B joins 3 months later with ₹30,000. What is the profit-sharing ratio at the end of the year?',
        options: ['8:9', '2:3', '4:5', '1:1'],
        correctAnswer: 0,
        difficulty: 'Medium',
        topic: 'Aptitude',
        concept: 'Partnership',
        explanation: "A's investment = 20,000 × 12 = 240,000. B's investment = 30,000 × 9 = 270,000. Ratio = 240:270 = 8:9.",
        tags: ['aptitude', 'partnership'],
      ),
      QuestionModel(
        id: 2,
        questionText: 'If in a certain code, MONKEY is written as XDJMNL, how is TIGER written in that code?',
        options: ['QDFHS', 'SDFHQ', 'UJHFS', 'SHFDQ'],
        correctAnswer: 0,
        difficulty: 'Medium',
        topic: 'Logical',
        concept: 'Coding-Decoding',
        explanation: 'Each letter is shifted back by 1 and the order is reversed.',
        tags: ['logical', 'coding'],
      ),
      QuestionModel(
        id: 3,
        questionText: 'Choose the word that is most nearly opposite in meaning to CANDID:',
        options: ['Deceptive', 'Frank', 'Honest', 'Sincere'],
        correctAnswer: 0,
        difficulty: 'Easy',
        topic: 'Verbal',
        concept: 'Antonyms',
        explanation: 'Candid means truthful; deceptive means misleading.',
        tags: ['verbal', 'vocabulary'],
      ),
      QuestionModel(
        id: 4,
        questionText: 'What is the time complexity of searching an element in a balanced BST?',
        options: ['O(log n)', 'O(n)', 'O(1)', 'O(n log n)'],
        correctAnswer: 0,
        difficulty: 'Easy',
        topic: 'Coding',
        concept: 'Data Structures',
        explanation: 'A balanced BST eliminates half the remaining nodes with each step.',
        tags: ['coding', 'trees'],
      ),
      QuestionModel(
        id: 5,
        questionText: 'A train running at 60 km/hr crosses a pole in 9 seconds. What is the length of the train?',
        options: ['150 metres', '120 metres', '180 metres', '324 metres'],
        correctAnswer: 0,
        difficulty: 'Easy',
        topic: 'Aptitude',
        concept: 'Time and Distance',
        explanation: 'Speed = 60 × (5/18) = 50/3 m/sec. Length = 50/3 × 9 = 150m.',
        tags: ['aptitude', 'trains'],
      ),
    ];
  }

  void _startCompanyTest(String company) async {
    final exam = context.read<ExamProvider>();
    try {
      final data = await _api.getCompanyTest(company);
      exam.startExam(
        title: '$company Mock Test',
        type: 'company',
        durationMinutes: data['time_minutes'] ?? 30,
        questionsList: data['questions'] ?? [],
      );
      widget.onStartExam();
    } catch (e) {
      // Offline fallback
      exam.startExam(
        title: '$company Mock Test',
        type: 'company',
        durationMinutes: 30,
        questionsList: _getMockQuestions(company),
      );
      widget.onStartExam();
    }
  }

  void _startQuickTest(String mode) async {
    final exam = context.read<ExamProvider>();
    try {
      final data = await _api.getQuickTest(mode);
      exam.startExam(
        title: data['title'] ?? 'Quick Test',
        type: 'quick',
        durationMinutes: data['time_minutes'] ?? 15,
        questionsList: data['questions'] ?? [],
      );
      widget.onStartExam();
    } catch (e) {
      // Offline fallback
      exam.startExam(
        title: 'Daily Challenge Drill',
        type: 'quick',
        durationMinutes: 15,
        questionsList: _getMockQuestions('Aptitude'),
      );
      widget.onStartExam();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // Sidebar matching Demo Video
          if (isWide)
            SizedBox(
              width: 240,
              child: _buildSidebar(auth),
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(user, auth),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    child: _buildCurrentTab(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide
          ? BottomNavigationBar(
              currentIndex: _selectedNavIndex.clamp(0, 4),
              onTap: (i) => setState(() => _selectedNavIndex = i),
              backgroundColor: AppColors.bg2,
              selectedItemColor: AppColors.accentLight,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Practice'),
                BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Companies'),
                BottomNavigationBarItem(icon: Icon(Icons.bolt_outlined), label: 'Quick Tests'),
                BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Ranks'),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebar(AuthProvider auth) {
    return Container(
      color: AppColors.bg2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo header matching Scene 2 (.s2-logo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF5227FF), Color(0xFFE040FB)],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'PlacePrep',
                    style: GoogleFonts.firaCode(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nav links matching Scene 2 (.s2-nav)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                _buildNavItem(0, 'Dashboard', '📊'),
                _buildNavItem(1, 'Practice Tests', '📝'),
                _buildNavItem(2, 'Company Tests', '🏢'),
                _buildNavItem(3, 'Quick Tests', '⚡'),
                _buildNavItem(4, 'Bookmarks', '🔖'),
                _buildNavItem(5, 'Leaderboard', '🏆', onTap: () {
                  _loadLeaderboard();
                  setState(() => _selectedNavIndex = 5);
                }),
                _buildNavItem(6, 'Analytics', '📈'),
                if (auth.isAdmin)
                  _buildNavItem(7, 'Admin Panel', '🛡️', onTap: () {
                    _loadAdminStats();
                    setState(() => _selectedNavIndex = 7);
                  }),
              ],
            ),
          ),

          const Spacer(),

          // Home / Exit link
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.textSecondary, size: 20),
            title: const Text('Landing Page', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            onTap: widget.onBackToLanding,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String emoji, {VoidCallback? onTap}) {
    final isSelected = _selectedNavIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentGlow : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Text(emoji, style: const TextStyle(fontSize: 16)),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.accentLight : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
        onTap: onTap ?? () => setState(() => _selectedNavIndex = index),
      ),
    );
  }

  Widget _buildTopHeader(UserModel? user, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user?.name.split(' ').first ?? 'Arjun'} 👋',
                style: GoogleFonts.firaCode(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              const Text('Track your progress and ace your placements', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              // Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.redGlow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text('${user?.streak ?? 7} Day Streak', style: const TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 18),
                onPressed: () async {
                  await auth.logout();
                  widget.onBackToLanding();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildScene2Dashboard();
      case 1:
        return _buildPracticeMode();
      case 2:
        return _buildScene5CompanyTests();
      case 3:
        return _buildQuickTests();
      case 4:
        return _buildBookmarks();
      case 5:
        return _buildLeaderboardView();
      case 6:
        return _buildScene6Analytics();
      case 7:
        return _buildAdminView();
      default:
        return _buildScene2Dashboard();
    }
  }

  // Exact Scene 2 — Dashboard from PlacePrep_Demo.mov
  Widget _buildScene2Dashboard() {
    final user = context.watch<AuthProvider>().user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Stat Cards in a row matching Scene 2 (.s2-stats)
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - (14 * 3)) / 4;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _buildDemoStatCard('Tests Taken', '${user?.testsTaken ?? 24}', '📋', AppColors.accentLight, cardWidth),
                _buildDemoStatCard('Accuracy', '${user?.totalAccuracy.toStringAsFixed(0) ?? '78'}%', '🎯', AppColors.green, cardWidth),
                _buildDemoStatCard('Questions', '${user?.questionsSolved ?? 412}', '✅', AppColors.yellow, cardWidth),
                _buildDemoStatCard('Streak', '${user?.streak ?? 7}🔥', '🔥', AppColors.red, cardWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // 2 Charts matching Scene 2 (.s2-charts)
        Row(
          children: [
            // Performance Trend Line
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📈 Performance Trend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 110,
                      child: AnimatedTrendChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Topic Proficiency Radar
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎯 Topic Proficiency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 110,
                      child: Center(
                        child: AnimatedRadarChart(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Start Section matching Scene 2 (.s2-quick)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚡ Quick Start', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildQuickPill('⚡ Daily Challenge', () => _startQuickTest('daily')),
                  _buildQuickPill('📝 Topic Practice', () => setState(() => _selectedNavIndex = 1)),
                  _buildQuickPill('🏢 Company Test', () => setState(() => _selectedNavIndex = 2)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoStatCard(String label, String value, String emoji, Color valColor, double width) {
    final numMatch = RegExp(r'(\d+)').firstMatch(value);
    final targetNum = numMatch != null ? int.tryParse(numMatch.group(1)!) : null;
    final suffix = targetNum != null ? value.substring(value.indexOf(numMatch!.group(1)!) + numMatch.group(1)!.length) : '';
    final prefix = targetNum != null ? value.substring(0, value.indexOf(numMatch!.group(1)!)) : '';

    return SizedBox(
      width: width,
      child: HoverCard(
        hoverBorderColor: valColor,
        hoverTranslateY: -3.0,
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                if (targetNum != null)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: targetNum.toDouble()),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return Text(
                        '$prefix${val.round()}$suffix',
                        style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: valColor),
                      );
                    },
                  )
                else
                  Text(value, style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: valColor)),
              ],
            ),
            Text(emoji, style: const TextStyle(fontSize: 26)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String title, VoidCallback onTap) {
    return _InteractivePill(title: title, onTap: onTap);
  }

  // Exact Scene 5 — Company Tests from PlacePrep_Demo.mov
  Widget _buildScene5CompanyTests() {
    final companyCards = [
      {
        'title': 'TCS NQT Foundation',
        'desc': 'No negative marking · Cannot revisit questions',
        'badge': 'TCS',
        'tags': ['🧮 Apt: 20Q/25m', '📝 Verbal: 25Q/25m', '🧩 Logic: 20Q/25m'],
        'meta': '65 Qs · 75 min',
        'startCo': 'TCS',
      },
      {
        'title': 'Wipro NLTH',
        'desc': 'Tight timing ~48s per aptitude question',
        'badge': 'Wipro',
        'tags': ['🧮 Apt: 20Q/16m', '📝 Verbal: 12Q/20m', '💻 Code: 10Q/60m'],
        'meta': '42 Qs · 96 min',
        'startCo': 'Wipro',
      },
      {
        'title': 'Cognizant GenC',
        'desc': 'Unique Automata Fix debugging section',
        'badge': 'Cognizant',
        'tags': ['🧮 Apt: 16Q', '🧩 Logic: 14Q', '💻 Automata Fix'],
        'meta': '64 Qs · 120 min',
        'startCo': 'Cognizant',
      },
      {
        'title': 'Infosys InfyTQ',
        'desc': 'Pseudo-code tracing focus',
        'badge': 'Infosys',
        'tags': ['🧮 Apt: 10Q', '🧩 Logic: 15Q', '💻 Code: 10Q'],
        'meta': '45 Qs · 105 min',
        'startCo': 'Infosys',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏢 Company Tests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Full-length placement simulations with exact patterns', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: companyCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 175,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, i) {
            final c = companyCards[i];
            final tags = c['tags'] as List<String>;

            return HoverCard(
              hoverBorderColor: AppColors.accentLight,
              hoverTranslateY: -4.0,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(c['desc'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGlow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(c['badge'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentLight)),
                      ),
                    ],
                  ),

                  Wrap(
                    spacing: 6,
                    children: tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bg3,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      );
                    }).toList(),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['meta'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _startCompanyTest(c['startCo'] as String),
                        child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Exact Scene 6 — Analytics from PlacePrep_Demo.mov
  Widget _buildScene6Analytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📈 Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Deep preparation insights', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),

        // 5 top stats matching Scene 6 (.s6-top-stats)
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - (12 * 4)) / 5;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAnalyticsKpi('Tests', '24', AppColors.accentLight, cardWidth),
                _buildAnalyticsKpi('Questions', '412', AppColors.green, cardWidth),
                _buildAnalyticsKpi('Avg Acc.', '78%', AppColors.yellow, cardWidth),
                _buildAnalyticsKpi('Avg Time/Q', '62s', AppColors.pink, cardWidth),
                _buildAnalyticsKpi('Best Score', '91%', AppColors.green, cardWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Two large charts matching Scene 6 (.s6-charts)
        Row(
          children: [
            // Accuracy Over Time
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Accuracy Over Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 160,
                      child: AnimatedTrendChart(isLong: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Topic Breakdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Topic Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTopicBar('Apt', 100, AppColors.yellow),
                          _buildTopicBar('Logic', 130, AppColors.purple),
                          _buildTopicBar('Verbal', 150, AppColors.green),
                          _buildTopicBar('Coding', 80, AppColors.red),
                          _buildTopicBar('DI', 110, AppColors.pink),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsKpi(String label, String val, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTopicBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 36,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildPracticeMode() {
    if (_isLoadingTopics) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📝 Practice Tests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Topic-wise practice across all 5 recruitment pillars', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topics.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final t = _topics[i];
            return HoverCard(
              hoverBorderColor: AppColors.accentLight,
              hoverTranslateY: -2.0,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(t['icon'] ?? '📚', style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text('${t['question_count']} questions', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _startTopicPractice(t['key'], t['name']),
                    child: const Text('Practice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚡ Quick Tests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Speed tests and marathons for quick placement drills', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildQuickPill('⚡ 10-Min Speed Sprint', () => _startQuickTest('sprint')),
            _buildQuickPill('📅 Daily Challenge (15 Qs)', () => _startQuickTest('daily')),
            _buildQuickPill('🎯 20-Q Mixed Drill', () => _startQuickTest('drill')),
            _buildQuickPill('🏃 60-Min Marathon Mock', () => _startQuickTest('marathon')),
          ],
        ),
      ],
    );
  }

  Widget _buildBookmarks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📌 Saved Bookmarks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Questions flagged during placement drills for quick revision', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        HoverCard(
          padding: const EdgeInsets.all(24),
          hoverBorderColor: AppColors.accentLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sample Bookmark • Partnership', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.yellowGlow, borderRadius: BorderRadius.circular(4)),
                    child: const Text('MEDIUM', style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('A starts a business with ₹20,000. B joins 3 months later with ₹30,000. What is the profit-sharing ratio at the end of the year?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.greenGlow, borderRadius: BorderRadius.circular(8)),
                child: const Text('Correct Answer: 8:9 (Ratio of effective capital: 240,000 : 270,000)', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardView() {
    if (_isLoadingLeaderboard) return const Center(child: CircularProgressIndicator());
    final liveTop = (_leaderboardData?['top_performers'] as List<LeaderboardUserModel>?);
    final top = (liveTop != null && liveTop.isNotEmpty)
        ? liveTop
        : [
            LeaderboardUserModel(rank: 1, userId: 101, name: 'Aarav Sharma', avatar: 'avatar-1', testsTaken: 42, questionsSolved: 620, streak: 14, accuracy: 94.2),
            LeaderboardUserModel(rank: 2, userId: 102, name: 'Priya Patel', avatar: 'avatar-2', testsTaken: 38, questionsSolved: 580, streak: 12, accuracy: 91.8),
            LeaderboardUserModel(rank: 3, userId: 103, name: 'Rohan Yakkali', avatar: 'avatar-3', testsTaken: 35, questionsSolved: 540, streak: 10, accuracy: 89.5),
            LeaderboardUserModel(rank: 4, userId: 104, name: 'Sneha Reddy', avatar: 'avatar-4', testsTaken: 31, questionsSolved: 490, streak: 9, accuracy: 87.0),
            LeaderboardUserModel(rank: 5, userId: 105, name: 'Vikram Malhotra', avatar: 'avatar-5', testsTaken: 28, questionsSolved: 450, streak: 7, accuracy: 85.4),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🏆 Leaderboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Top placement aspirants ranked by accuracy and questions solved', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('RANK')),
              DataColumn(label: Text('CANDIDATE')),
              DataColumn(label: Text('QUESTIONS')),
              DataColumn(label: Text('ACCURACY')),
              DataColumn(label: Text('STREAK')),
            ],
            rows: top.map((u) {
              return DataRow(cells: [
                DataCell(Text('#${u.rank}', style: GoogleFonts.firaCode(fontWeight: FontWeight.w700, color: AppColors.accentLight))),
                DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                DataCell(Text('${u.questionsSolved}', style: GoogleFonts.firaCode())),
                DataCell(Text('${u.accuracy}%', style: GoogleFonts.firaCode(color: AppColors.green))),
                DataCell(Text('🔥 ${u.streak}d', style: const TextStyle(color: AppColors.yellow))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminView() {
    if (_isLoadingAdmin) return const Center(child: CircularProgressIndicator());
    final s = _adminStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🛡️ Admin Panel', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        if (s != null)
          Text('Total Candidates: ${s['total_users']} • Total Exams: ${s['total_tests_taken']}', style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InteractivePill extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _InteractivePill({required this.title, required this.onTap});

  @override
  State<_InteractivePill> createState() => _InteractivePillState();
}

class _InteractivePillState extends State<_InteractivePill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0.0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0x386366F1) : const Color(0x1F6366F1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppColors.accentLight : AppColors.border,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: _isHovered ? Colors.white : AppColors.accentLight,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
