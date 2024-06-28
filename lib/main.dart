import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/pages/home.dart';
import 'package:gym_management/pages/insert.dart';
import 'package:gym_management/pages/list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MemberAdapter());
  await Hive.openBox<Member>('members');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Gym Management Application',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Main(),
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  static _MainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainState>();

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;

  void navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<StatefulWidget> _pages = [
    const HomePage(),
    const ListPage(),
    const InsertPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
