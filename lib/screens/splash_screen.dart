import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:cipher_schools_assignment/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));

    final authService = AuthService();
    final storedUserId = await authService.getStoredUserId();

    if (storedUserId != null) {
      final user = authService.currentUser;
      if (user != null && user.uid == storedUserId) {
        final userData = await authService.getUserData(storedUserId);
        if (userData != null) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, MyApp.homeRoute);
          }
          return;
        }
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, MyApp.welcomeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/splash_screen_bg.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/cipherX_logo.png'),
                SizedBox(height: 16),
                Image.asset('assets/CipherX_text.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
