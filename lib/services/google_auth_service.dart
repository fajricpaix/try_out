import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:try_out/services/auth_session_service.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleSignInInitialization;
  static Future<UserCredential>? _ongoingSignIn;
  static DateTime? _lastAttemptAt;
  static const Duration _rapidCancelWindow = Duration(milliseconds: 1500);

  static Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

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

  static Future<UserCredential> _performGoogleSignIn({bool isRetry = false}) async {
    final DateTime startedAt = DateTime.now();

    try {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount? existingAccount =
          await _googleSignIn.attemptLightweightAuthentication();
      final GoogleSignInAccount googleUser =
          existingAccount ??
          await _googleSignIn.authenticate(
            scopeHint: const ['email'],
          );

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Sign-In belum terkonfigurasi dengan benar (idToken kosong). '
          'Perbarui google-services.json dari Firebase Console dan pastikan SHA-1/SHA-256 sudah ditambahkan.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      final bool likelyInternalCancellation =
          e.code == GoogleSignInExceptionCode.canceled &&
          !isRetry &&
          DateTime.now().difference(startedAt) <= _rapidCancelWindow;

      if (likelyInternalCancellation) {
        return _retryGoogleSignInAfterQuickCancel();
      }

      throw Exception(_mapGoogleSignInError(e));
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

  static Future<UserCredential> _retryGoogleSignInAfterQuickCancel() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore sign-out failure; retry authenticate anyway.
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _performGoogleSignIn(isRetry: true);
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

  static String _mapGoogleSignInError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return kIsWeb
            ? 'Login Google dibatalkan. Pilih akun Google dan izinkan popup browser jika diminta.'
            : 'Login Google dibatalkan. Jika ini terjadi terus, tunggu 1-2 detik lalu coba lagi.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Proses login Google terhenti. Coba lagi.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return e.description ??
            'Google Sign-In belum terkonfigurasi dengan benar. Periksa konfigurasi Firebase dan OAuth client.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'UI login Google tidak tersedia saat ini. Tutup dialog yang bentrok lalu coba lagi.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Akun Google yang dipilih tidak cocok dengan sesi yang aktif. Silakan logout lalu coba lagi.';
      case GoogleSignInExceptionCode.unknownError:
        return e.description ?? 'Terjadi kesalahan saat login Google.';
    }
  }

  static Future<UserCredential> loginWithGoogle() async {
    return _signInWithGoogle();
  }

  static Future<UserCredential> registerWithGoogle() async {
    return _signInWithGoogle();
  }

  static Future<UserCredential> loginOrRegisterWithGoogle() async {
    final credential = await _signInWithGoogle();
    if (credential.user != null) {
      await AuthSessionService.saveUserSession(credential.user!, 'google');
    }
    return credential;
  }

  static Future<UserCredential> loginAsUser(String userName) async {
    try {
      final UserCredential credential = await _auth.signInAnonymously();
      User? user = credential.user;

      if (user != null && (user.displayName ?? '').trim() != userName) {
        await user.updateDisplayName(userName);
        await user.reload();

        // Read the latest instance after reload so UI/session use updated displayName.
        user = _auth.currentUser;
      }

      if (user != null) {
        await AuthSessionService.saveUserSession(user, 'anonymous');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed' ||
          e.code == 'admin-restricted-operation') {
        throw Exception(
          'Login as user belum diaktifkan. Aktifkan Anonymous di Firebase Console > Authentication > Sign-in method.',
        );
      }
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  static Future<void> signOut() async {
    await AuthSessionService.clearUserSession();
    await _auth.signOut();
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }
}
