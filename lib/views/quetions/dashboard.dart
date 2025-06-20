import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:try_out/views/quetions/quiz.dart';
import 'package:try_out/widgets/tools/box_quiz.dart';

class DashboardQuetionView extends StatefulWidget {
  const DashboardQuetionView({super.key});

  @override
  State<DashboardQuetionView> createState() => _DashboardQuetionViewState();
}

class _DashboardQuetionViewState extends State<DashboardQuetionView> {
  Map<String, dynamic>? quizData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/dummy.json',
      );
      final data = json.decode(response);
      setState(() {
        quizData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load quiz data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A5AE0),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        body: Center(
          child: Text(
            _error,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final keys = quizData!.keys.toList();

    return DefaultTabController(
      length: keys.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF6A5AE0),
        appBar: AppBar(
          title: const Text(
            'Latihan Soal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color(0xFF6A5AE0),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Image.asset(
                'assets/training/question.webp',
                width: 250,
                height: 250,
              ),
            ),
            TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2),
                insets: EdgeInsets.only(bottom: 8),
              ),
              dividerColor: Colors.transparent,
              tabs: keys.map((key) {
                final title = quizData![key]['title'] ?? key.toUpperCase();
                return Tab(text: title);
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: keys.map((key) {
                  final data = quizData![key];
                  return QuizPreviewTabContent(
                    title: data['title'] ?? '',
                    desc: data['desc'] ?? '',
                    level: data['level'] ?? '',
                    quizList: data['quiz'] ?? [],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPreviewTabContent extends StatelessWidget {
  final String title;
  final String desc;
  final String level;
  final List quizList;

  const QuizPreviewTabContent({
    super.key,
    required this.title,
    required this.desc,
    required this.level,
    required this.quizList,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latihan Soal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A5AE0)),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BoxQuizComponents(
                  label: 'Jumlah Soal',
                  text: '${quizList.length}',
                ),
                const SizedBox(width: 16),
                BoxQuizComponents(label: 'Tingkat Kesulitan', text: level),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizView(quizData: quizList),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Latihan Soal',
                style: TextStyle(fontSize: 16, color: Color(0xFF6A5AE0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
