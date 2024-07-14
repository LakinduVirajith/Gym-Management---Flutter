// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/pages/sign_up.dart';
import 'package:gym_management/services/mongo_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  // Initializes the splash screen by waiting for necessary setup tasks to complete
  Future<void> _initializeSplash() async {
    await Future.wait([
      _navigateToMain(),
    ]);
    _updateLastActiveTime();
    _initializePaymentVerifier();
  }

  // Updates the last active time for the user in the database
  Future<void> _updateLastActiveTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mobileNumber = (prefs.getString('mobile_number') ?? '');

    if (mobileNumber.isNotEmpty) {
      final MongoService mongoService = MongoService();
      try {
        await mongoService.connect();
        await mongoService.updateUserLastActiveDate(
            mobileNumber, DateTime.now());
        await mongoService.disconnect();
      } catch (e) {
        return;
      }
    }
  }

  // Initializes the payment verifier by setting up SharedPreferences and ToastService
  Future<void> _initializePaymentVerifier() async {
    // Initialize SharedPreferences for local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Initialize ToastService for displaying messages
    final ToastService toastService = ToastService();

    // Call paymentVerifier to check and handle payment due dates
    await _paymentVerifier(prefs, context, toastService);
  }

  // Function to verify and handle payment due dates
  Future<void> _paymentVerifier(SharedPreferences prefs, BuildContext context,
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
      // // Calculate the difference in days between payment due date and today
      // DateTime today = DateTime.now().add(const Duration(days: -1));
      // int differenceInDays = paymentDueDate!.difference(today).inDays;

      // if (differenceInDays == 0) {
      //   // Navigate to a specific page if payment due date is today
      //   Navigator.of(context)
      //       .push(MaterialPageRoute(builder: (_) => const PaymentPage()));
      // } else if (differenceInDays <= 2 && differenceInDays > 0) {
      //   // Display an alert message if payment due date is within 2 days from today
      //   toastService.infoToast('your payment is due in $differenceInDays days.');
      // }
    }
  }

// Navigates to the main screen after a delay
  Future<void> _navigateToMain() async {
    await Future.delayed(
      const Duration(milliseconds: 2500),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Main(),
      ),
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
            const SizedBox(height: 64.0),
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
