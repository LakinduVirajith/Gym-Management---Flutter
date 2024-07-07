import 'package:flutter/material.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

Future<void> _signUp() async {
  // Initialize SharedPreferences for local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();

  DateTime appStartDate = DateTime.now();
  await prefs.setString('app_start_date', appStartDate.toIso8601String());

  DateTime paymentDueDate = AppDateUtils.addOneMonth(appStartDate);
  await prefs.setString('payment_due_date', paymentDueDate.toIso8601String());
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Text('Sign Up Page'),
      ),
    );
  }
}
