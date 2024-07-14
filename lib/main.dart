import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/pages/contact_us.dart';
import 'package:gym_management/pages/home.dart';
import 'package:gym_management/pages/insert.dart';
import 'package:gym_management/pages/list.dart';
import 'package:gym_management/splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register the MemberAdapter for Hive
  Hive.registerAdapter(MemberAdapter());

  // Open the Hive box named 'members' to store Member objects
  await Hive.openBox<Member>('members');

  // Load the environment variables from the .env file to access configuration details
  await dotenv.load(fileName: ".env");

  // Run the app with MyApp as the root widget
  runApp(
    ToastificationWrapper(
      child: MaterialApp(
        title: 'Gym Management Application',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    ),
  );
}

// The main page widget with navigation and payment verification
class Main extends StatefulWidget {
  const Main({super.key});

  static MainState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainState>();

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
  int _selectedIndex = 0;

  // Updates the selected navigation tab index
  void navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of pages for navigation
  final List<StatefulWidget> _pages = [
    const HomePage(),
    const ListPage(),
    const InsertPage(),
  ];

  // Method to navigate to the contact us page of the application
  void _contactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.contact_support_sharp,
                    color: Colors.white,
                  ),
                  onPressed: _contactUs,
                ),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 20.0,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.white10,
            padding: const EdgeInsets.all(16.0),
            gap: 8,
            selectedIndex: _selectedIndex,
            onTabChange: navigate,
            tabs: const [
              GButton(
                icon: Icons.home_rounded,
                text: 'Home',
              ),
              GButton(
                icon: Icons.people_alt_rounded,
                text: 'List',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          navigate(2);
        },
        tooltip: 'Insert',
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white,
            width: 4.0,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
