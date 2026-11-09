import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/exam_provider.dart';
import 'views/landing_view.dart';
import 'views/dashboard_view.dart';
import 'views/exam_view.dart';
import 'views/results_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: const PlacePrepApp(),
    ),
  );
}

class PlacePrepApp extends StatelessWidget {
  const PlacePrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlacePrep — Ace Every Interview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  bool _forceDashboard = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final exam = context.watch<ExamProvider>();

    // 1. If an active test is running, show ExamView
    if (exam.isExamActive) {
      return ExamView(
        onFinish: () => setState(() {}),
      );
    }

    // 2. If test just finished and has results, show ResultsView
    if (exam.lastResult != null) {
      return ResultsView(
        result: exam.lastResult!,
        onBackToDashboard: () {
          exam.resetExam();
          setState(() => _forceDashboard = true);
        },
      );
    }

    // 3. If logged in or user clicked into app, show Dashboard
    if (auth.isLoggedIn || _forceDashboard) {
      return DashboardView(
        onStartExam: () => setState(() {}),
        onBackToLanding: () => setState(() => _forceDashboard = false),
      );
    }

    // 4. Default: Show beautiful Landing Page
    return LandingView(
      onEnterApp: () => setState(() => _forceDashboard = true),
    );
  }
}
