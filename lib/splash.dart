import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

enum NavigationTarget { main, login, signup }

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _handleSplashNavigation();
  }

  void _handleSplashNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = _authService.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final hasAppStartDate =
          prefs.getString('app_start_date')?.isNotEmpty ?? false;

      if (user != null) {
        await _navigateTo(NavigationTarget.main);
      } else if (hasAppStartDate) {
        await _navigateTo(NavigationTarget.login);
      } else {
        await _navigateTo(NavigationTarget.signup);
      }
    });
  }

  Future<void> _navigateTo(NavigationTarget target) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    String route;
    switch (target) {
      case NavigationTarget.main:
        route = '/main';
        break;
      case NavigationTarget.login:
        route = '/login';
        break;
      case NavigationTarget.signup:
        route = '/signup';
        break;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/application_logo.png'),
              ),
            ),
            const SizedBox(height: 64),
            const SpinKitWave(
              color: Colors.black,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
