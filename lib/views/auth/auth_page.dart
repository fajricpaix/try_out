import 'package:flutter/material.dart';
import 'package:try_out/services/google_auth_service.dart';
import 'dart:math';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isProcessing = false;
  late final String _generatedUserName;

  @override
  void initState() {
    super.initState();
    _generatedUserName = _buildUserName();
  }

  String _buildUserName() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random.secure();
    final String suffix = List.generate(
      10,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'CPNS-$suffix';
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await action();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFC7E37),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFFC7E37),
        foregroundColor: Colors.white,
        titleSpacing: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bank Soal CPNS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Akun Google',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in Google untuk login atau registrasi otomatis dalam satu langkah.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _runAuth(() async {
                                  await GoogleAuthService.loginOrRegisterWithGoogle();
                                }),
                        icon: const Icon(Icons.login),
                        label: const Text('Sign In with Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E00B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _runAuth(() async {
                                  await GoogleAuthService.loginAsUser(
                                    _generatedUserName,
                                  );
                                }),
                        icon: const Icon(Icons.person),
                        label: const Text('Sign In as Guest'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5E00B0),
                          side: const BorderSide(color: Color(0xFF5E00B0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
