import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ReportQuestionPage extends StatefulWidget {
  const ReportQuestionPage({
    super.key,
    required this.questionId,
    required this.userName,
    required this.questionText,
    required this.options,
    required this.explanation,
    required this.selectedOptionLabel,
  });

  final String questionId;
  final String userName;
  final String questionText;
  final List<Map<String, dynamic>> options;
  final String explanation;
  final String? selectedOptionLabel;

  @override
  State<ReportQuestionPage> createState() => _ReportQuestionPageState();
}

class _ReportQuestionPageState extends State<ReportQuestionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reportController = TextEditingController();
  final DatabaseReference _reportRef = FirebaseDatabase.instance.ref(
    'report-user',
  );

  bool _isSaving = false;

  String _buildOptionsText() {
    return widget.options
        .map((option) {
          final String label = option['label']?.toString() ?? '-';
          final String text = option['text']?.toString() ?? '-';
          return '$label. $text';
        })
        .join('\n');
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final payload = <String, dynamic>{
      'idSoal': widget.questionId,
      'namaUser': widget.userName,
      'question': widget.questionText,
      'pilihanJawaban': widget.options
          .map(
            (option) => {
              'label': option['label']?.toString(),
              'text': option['text']?.toString(),
            },
          )
          .toList(),
      'selectedOptionLabel': widget.selectedOptionLabel,
      'explanation': widget.explanation,
      'formReport': _reportController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await _reportRef.push().set(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report berhasil dikirim.')));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim report. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Soal', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A5AE0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: widget.questionText,
              readOnly: true,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _buildOptionsText(),
              readOnly: true,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Jawaban A-E',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.explanation,
              readOnly: true,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Penjelasan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reportController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Form Report',
                hintText: 'Tuliskan masalah pada soal ini...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Form report wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
