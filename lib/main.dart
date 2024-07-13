import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/pages/contact_us.dart';
import 'package:gym_management/pages/home.dart';
import 'package:gym_management/pages/insert.dart';
import 'package:gym_management/pages/list.dart';
import 'package:gym_management/pages/payment.dart';
import 'package:gym_management/pages/sign_up.dart';
import 'package:gym_management/services/mongo_service.dart';
import 'package:gym_management/services/toast_service.dart';
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

  // Load the environment variables from the .env file to access configuration details
  await dotenv.load(fileName: ".env");

  // Call function to update last active time for the user
  await updateLastActiveTime();

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

  static MainState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainState>();

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePaymentVerifier();
  }

  // Initializes the payment verifier by setting up SharedPreferences and ToastService
  Future<void> _initializePaymentVerifier() async {
    // Initialize SharedPreferences for local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Initialize ToastService for displaying messages
    final ToastService toastService = ToastService();

    // Call paymentVerifier to check and handle payment due dates
    await _paymentVerifier(prefs, toastService);
  }

  // Verifies and handles payment due dates
  Future<void> _paymentVerifier(
      SharedPreferences prefs, ToastService toastService) async {
    await paymentVerifier(prefs, context, toastService);
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

  // Method to navigate to the contact us page of the application
  void _contactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializePaymentVerifier(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        }
      },
    );
  }
}

// Function to update last active time for a user
Future<void> updateLastActiveTime() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String mobileNumber = (prefs.getString('mobile_number') ?? '');

  if (mobileNumber.isNotEmpty) {
    final MongoService mongoService = MongoService();
    try {
      await mongoService.connect();
      await mongoService.updateUserLastActiveDate(mobileNumber, DateTime.now());
      await mongoService.disconnect();
    } catch (e) {
      return;
    }
  }
}

// Function to verify and handle payment due dates
Future<void> paymentVerifier(SharedPreferences prefs, BuildContext context,
    ToastService toastService) async {
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
      toastService.infoToast('your payment is due in $differenceInDays days.');
    }
  }
}
