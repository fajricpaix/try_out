import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try_out/views/home/header/slide_header.dart';

class HeaderTopBar extends StatelessWidget {
  const HeaderTopBar({
    super.key,
    required this.user,
    required this.onAccountPressed,
  });

  final User? user;
  final VoidCallback onAccountPressed;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = user != null;
    final String? photoUrl = user?.photoURL;
    final int currentEnergy = 100;
    final int maxEnergy = 100;
    final double energyProgress = (currentEnergy / maxEnergy)
        .clamp(0.0, 1.0)
        .toDouble();
    final Color energyColor = currentEnergy < 10
        ? Colors.red
        : currentEnergy < 50
        ? Colors.yellow
        : Colors.green;
    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'User');

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: energyColor, size: 24),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 16,
                          value: energyProgress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
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
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF5E00B0), size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onAccountPressed,
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
