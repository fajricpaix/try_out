import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  static Future<UserCredential>? _ongoingSignIn;
  static DateTime? _lastAttemptAt;

  static Future<UserCredential> _signInWithGoogle() async {
    final DateTime now = DateTime.now();
    if (_lastAttemptAt != null &&
        now.difference(_lastAttemptAt!).inMilliseconds < 1200) {
      throw Exception('Tunggu sebentar, lalu coba login Google lagi.');
    }
    _lastAttemptAt = now;

    if (_ongoingSignIn != null) {
      return _ongoingSignIn!;
    }

    _ongoingSignIn = _performGoogleSignIn();

    try {
      return await _ongoingSignIn!;
    } finally {
      _ongoingSignIn = null;
    }
  }

  static Future<UserCredential> _performGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Login dibatalkan oleh pengguna.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Sign-In belum terkonfigurasi dengan benar (idToken kosong). '
          'Perbarui google-services.json dari Firebase Console dan pastikan SHA-1/SHA-256 sudah ditambahkan.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on PlatformException catch (e) {
      final String msg = (e.message ?? '').toUpperCase();
      if (msg.contains('PHASE_CLIENT_ALREADY_HIDDEN')) {
        throw Exception(
          'Proses login Google sedang bentrok. Tutup popup Google jika masih terbuka, lalu coba lagi.',
        );
      }
      throw Exception('Google Sign-In gagal (${e.code}): ${e.message ?? 'Unknown error'}');
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      final String raw = e.toString().toUpperCase();
      if (raw.contains('PHASE_CLIENT_ALREADY_HIDDEN') ||
          raw.contains('ONCANCELLED AT PHASE_CLIENT_ALREADY_HIDDEN')) {
        throw Exception(
          'Google Sign-In dibatalkan karena bentrok proses internal. Coba lagi 1-2 detik setelah popup tertutup.',
        );
      }
      if (e is Exception) rethrow;
      throw Exception('Gagal login Google: $e');
    }
  }

  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Coba lagi.';
      case 'invalid-credential':
      case 'account-exists-with-different-credential':
        return 'Kredensial Google tidak valid. Cek konfigurasi Firebase Google Sign-In.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      default:
        return 'Gagal autentikasi (${e.code}): ${e.message ?? 'Unknown error'}';
    }
  }

  static Future<UserCredential> loginWithGoogle() async {
    return _signInWithGoogle();
  }

  static Future<UserCredential> registerWithGoogle() async {
    return _signInWithGoogle();
  }

  static Future<UserCredential> loginOrRegisterWithGoogle() async {
    return _signInWithGoogle();
  }

  static Future<UserCredential> loginAsUser(String userName) async {
    final UserCredential credential = await _auth.signInAnonymously();
    final User? user = credential.user;

    if (user != null && (user.displayName ?? '').trim() != userName) {
      await user.updateDisplayName(userName);
      await user.reload();
    }

    return credential;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
