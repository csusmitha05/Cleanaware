import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_wrapper_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AuthWrapperScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F766E), Color(0xFF34D399)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -60,
              child: _bgCircle(260, Colors.white.withValues(alpha: 0.12)),
            ),
            Positioned(
              bottom: -120,
              left: -70,
              child: _bgCircle(300, Colors.black.withValues(alpha: 0.10)),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _EcoBadge(),
                    SizedBox(height: 22),
                    Text(
                      'Cleanliness & Environmental Awareness',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Report issues. Protect spaces. Build greener neighborhoods.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE8FFF9),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bgCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _EcoBadge extends StatelessWidget {
  const _EcoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          CircleAvatar(
            radius: 54,
            backgroundColor: Color(0xE6FFFFFF),
            child: Icon(Icons.public_rounded, color: Color(0xFF0F766E), size: 50),
          ),
          Positioned(
            bottom: 43,
            right: 47,
            child: Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 25),
          ),
        ],
      ),
    );
  }
}
