import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gym_management/pages/contact_us.dart';
import 'package:gym_management/pages/home.dart';
import 'package:gym_management/pages/insert.dart';
import 'package:gym_management/pages/list.dart';
import 'package:gym_management/pages/login.dart';
import 'package:gym_management/pages/sign_up.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/splash.dart';
import 'package:gym_management/utils/dialog_utils.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gym Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/main': (context) => const Main(),
          '/contact': (context) => const ContactUsPage(),
        },
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  static MainState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainState>();

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
  int _selectedIndex = 0;

  void navigate(int index) => setState(() => _selectedIndex = index);

  final List<Widget> _pages = [
    const HomePage(),
    const ListPage(),
    const InsertPage(),
  ];

  void _contactUs() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/contact', (Route<dynamic> route) => false);
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.signOut();

    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) showExitConfirmation(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Gym Management',
              style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
            IconButton(
              icon: const Icon(Icons.question_answer, color: Colors.white),
              onPressed: _contactUs,
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.white10,
              padding: const EdgeInsets.all(16),
              gap: 8,
              selectedIndex: _selectedIndex,
              onTabChange: navigate,
              tabs: const [
                GButton(icon: Icons.home_rounded, text: 'Home'),
                GButton(icon: Icons.people_alt_rounded, text: 'List'),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => navigate(2),
          backgroundColor: Colors.black,
          tooltip: 'Insert',
          shape: const CircleBorder(
              side: BorderSide(color: Colors.white, width: 4)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
