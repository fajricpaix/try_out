import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:try_out/services/energy_service.dart';
import 'package:try_out/widgets/ads/ads_constant.dart';
import 'package:try_out/views/home/header/slide_header.dart';

class HeaderTopBar extends StatefulWidget {
  const HeaderTopBar({
    super.key,
    required this.user,
    required this.onAccountPressed,
  });

  final User? user;
  final VoidCallback onAccountPressed;

  @override
  State<HeaderTopBar> createState() => _HeaderTopBarState();
}

class _HeaderTopBarState extends State<HeaderTopBar> {
  bool _isTopUpInProgress = false;
  bool _showEnergyCountdownHint = false;
  String _energyCountdownHintText = '';
  Timer? _energyCountdownTicker;
  Timer? _energyCountdownHideTimer;

  String _formatDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int minutes = (totalSeconds ~/ 60) % 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showEnergyCountdownHintView() async {
    if (_showEnergyCountdownHint) {
      return;
    }

    final Duration? until = await EnergyService.getTimeUntilNextRegen(
      widget.user,
    );
    if (!mounted) return;

    _energyCountdownTicker?.cancel();
    _energyCountdownHideTimer?.cancel();

    Duration remaining = until ?? Duration.zero;
    setState(() {
      _showEnergyCountdownHint = true;
      _energyCountdownHintText = until == null
          ? 'Energi sudah penuh.'
          : 'Energi +1 dalam ${_formatDuration(remaining)}';
    });

    if (until != null) {
      _energyCountdownTicker = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (remaining.inSeconds <= 0) {
          timer.cancel();
          await EnergyService.syncEnergyForUser(widget.user);
          setState(() {
            _energyCountdownHintText = 'Energi siap bertambah.';
          });
          return;
        }
        remaining = Duration(seconds: remaining.inSeconds - 1);
        setState(() {
          _energyCountdownHintText =
              'Energi +1 dalam ${_formatDuration(remaining)}';
        });
      });
    }

    _energyCountdownHideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _showEnergyCountdownHint = false;
      });
      _energyCountdownTicker?.cancel();
      _energyCountdownTicker = null;
    });
  }

  void _showTopSuccessEnergyBanner(int energy) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.green,
        content: Text(
          'Energy +${EnergyService.adRewardEnergy} berhasil. Energy sekarang: $energy',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.check_circle, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      messenger.hideCurrentMaterialBanner();
    });
  }

  void _showGuestEnergyLimitBanner() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFFEF6C00),
        content: const Text(
          'Belum login: energi maksimal 100. Login agar bonus energi bisa lebih dari 100.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: const Icon(Icons.info_outline, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      messenger.hideCurrentMaterialBanner();
    });
  }

  @override
  void initState() {
    super.initState();
    EnergyService.syncEnergyForUser(widget.user);
  }

  @override
  void dispose() {
    _energyCountdownTicker?.cancel();
    _energyCountdownHideTimer?.cancel();
    super.dispose();
  }

  Future<InterstitialAd?> _loadTopUpAd() async {
    final Completer<InterstitialAd?> completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: AdsConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) {
            completer.complete(ad);
          }
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    return completer.future;
  }

  Future<void> _handleTopUpPressed() async {
    if (_isTopUpInProgress) return;

    final bool isGuest = widget.user == null;
    final int beforeEnergy = await EnergyService.getCurrentEnergy(widget.user);
    if (isGuest) {
      _showGuestEnergyLimitBanner();
      if (beforeEnergy >= EnergyService.defaultEnergy) {
        return;
      }
    }

    setState(() {
      _isTopUpInProgress = true;
    });

    final InterstitialAd? ad = await _loadTopUpAd();
    if (ad == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iklan belum siap, coba lagi sebentar.'),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isTopUpInProgress = false;
        });
      }
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) async {
        shownAd.dispose();
        final int energy = await EnergyService.addEnergyFromAd(widget.user);
        if (!mounted) return;
        setState(() {
          _isTopUpInProgress = false;
        });
        final int gained = energy - beforeEnergy;
        if (gained > 0) {
          _showTopSuccessEnergyBanner(energy);
        }
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        if (!mounted) return;
        setState(() {
          _isTopUpInProgress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menampilkan iklan.')),
        );
      },
    );

    ad.show();
  }

  @override
  void didUpdateWidget(covariant HeaderTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? oldUid = oldWidget.user?.uid;
    final String? newUid = widget.user?.uid;
    if (oldUid != newUid) {
      EnergyService.syncEnergyForUser(widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = widget.user != null;
    final String? photoUrl = widget.user?.photoURL;
    final int maxEnergy = 100;
    final String userName = widget.user?.displayName?.trim().isNotEmpty == true
        ? widget.user!.displayName!.trim()
        : (widget.user?.email?.split('@').first ?? 'User');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(28),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: EnergyService.energyNotifier,
              builder: (context, currentEnergy, _) {
                final double energyProgress = (currentEnergy / maxEnergy)
                    .clamp(0.0, 1.0)
                    .toDouble();
                final Color energyColor = currentEnergy < 10
                    ? Colors.red
                    : currentEnergy < 50
                    ? Colors.yellow
                    : Colors.green;

                return Row(
                  children: [
                    _showEnergyCountdownHint
                        ? Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _energyCountdownHintText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: _showEnergyCountdownHintView,
                            borderRadius: BorderRadius.circular(18),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: energyColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          minHeight: 16,
                                          value: energyProgress,
                                          backgroundColor: Colors.white24,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                energyColor,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '$currentEnergy/$maxEnergy',
                                        style: const TextStyle(
                                          color: Color(0xFF3E2A00),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _isTopUpInProgress ? null : _handleTopUpPressed,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF5E00B0),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: widget.onAccountPressed,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage: isLoggedIn && photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: isLoggedIn && photoUrl != null
                        ? null
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF5E00B0),
                            size: 18,
                          ),
                  ),
                  if (!isLoggedIn) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            'AYO BERGABUNG MENJADI ASN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'BERKARYA UNTUK TANAH AIR, BERSAMA MEWUJUDKAN INDONESIA MAJU',
            style: TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          SlideHeader(),
        ],
      ),
    );
  }
}
