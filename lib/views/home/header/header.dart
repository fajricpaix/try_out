import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:try_out/views/home/header/slide_header.dart';

class Header extends StatelessWidget {
  const Header({
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
    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'User');

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onAccountPressed,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
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
              ),
              const SizedBox(height: 10),
              const Text(
                'AYO BERGABUNG MENJADI ASN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Text(
                'BERKARYA UNTUK TANAH AIR, BERSAMA MEWUJUDKAN INDONESIA MAJU',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const SlideHeader(),
            ],
          ),
        ),
      ],
    );
  }
}
