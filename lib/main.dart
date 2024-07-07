import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/pages/home.dart';
import 'package:gym_management/pages/insert.dart';
import 'package:gym_management/pages/list.dart';
import 'package:gym_management/pages/payment.dart';
import 'package:gym_management/pages/sign_up.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Run the app with MyApp as the root widget
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

// The main page widget with navigation and payment verification
class Main extends StatefulWidget {
  const Main({super.key});

  static _MainState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainState>();

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _paymentVerifier();
  }

  // Verifies and handles payment due dates
  Future<void> _paymentVerifier() async {
    // Initialize SharedPreferences for local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Call paymentVerifier to check and handle payment due dates
    paymentVerifier(prefs, context);
  }

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

// Function to verify and handle payment due dates
void paymentVerifier(SharedPreferences prefs, BuildContext context) async {
  DateTime? appStartDate =
      DateTime.tryParse(prefs.getString('app_start_date') ?? '');
  DateTime? paymentDueDate =
      DateTime.tryParse(prefs.getString('payment_due_date') ?? '');

  // If both app start date and payment due date are not set, navigate to the SignUpPage
  if (appStartDate == null && paymentDueDate == null) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SignUpPage()));
  } else {
    // Calculate the difference in days between payment due date and today
    DateTime today = DateTime.now().add(const Duration(days: -1));
    int differenceInDays = paymentDueDate!.difference(today).inDays;

    if (differenceInDays == 0) {
      // Navigate to a specific page if payment due date is today
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PaymentPage()));
    } else if (differenceInDays <= 2 && differenceInDays > 0) {
      // Display an alert message if payment due date is within 2 days from today
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Payment Reminder'),
            content: Text('Your payment is due in $differenceInDays days.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
