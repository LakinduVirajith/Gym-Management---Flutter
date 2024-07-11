import 'package:flutter/material.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/models/user.dart';
import 'package:gym_management/services/mongo_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';
import 'package:gym_management/widgets/number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // TextEditingControllers for form fields
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _gymNameController = TextEditingController();
  final TextEditingController _gymAddressController = TextEditingController();

  // Services for database operations and displaying toast messages
  final MongoService _mongoService = MongoService();
  final ToastService _toastService = ToastService();

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Connect to the MongoDB database on initialization
    _mongoService.connect();
  }

  @override
  void dispose() {
    // Disconnect from the MongoDB database and dispose of controllers
    _mongoService.disconnect();
    _userNameController.dispose();
    _mobileNumberController.dispose();
    _gymNameController.dispose();
    _gymAddressController.dispose();
    super.dispose();
  }

  // Method to clear all form fields
  void _clean() {
    _userNameController.clear();
    _mobileNumberController.clear();
    _gymNameController.clear();
    _gymAddressController.clear();
  }

  // Method to handle user sign up
  Future<void> _signUp() async {
    final String userName = _userNameController.text.trim();
    final String mobileNumber = _mobileNumberController.text.trim();
    final String gymName = _gymNameController.text.trim();
    final String gymAddress = _gymAddressController.text.trim();
    final DateTime appStartDate = DateTime.now();
    final DateTime paymentDueDate = AppDateUtils.addOneMonth(appStartDate);

    // Check if all fields are filled
    if (userName.isEmpty ||
        mobileNumber.isEmpty ||
        gymName.isEmpty ||
        gymAddress.isEmpty) {
      _toastService.warningToast('Please fill in all fields');
      return;
    }

    // Check if mobile number is unique
    bool isUnique = await _mongoService.isMobileNumberUnique(mobileNumber);
    if (!isUnique) {
      _toastService.warningToast('Mobile number already used');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Create user object
      User user = User(
        userName: userName,
        mobileNumber: mobileNumber,
        gymName: gymName,
        gymAddress: gymAddress,
        appStartDate: appStartDate.toIso8601String(),
        paymentDueDate: paymentDueDate.toIso8601String(),
        lastActiveDate: appStartDate.toIso8601String(),
      );

      // Insert user into the database
      await _mongoService.insertUser(user.toJson());

      // Save user information in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', userName);
      await prefs.setString('mobile_number', mobileNumber);
      await prefs.setString('app_start_date', appStartDate.toIso8601String());
      await prefs.setString(
          'payment_due_date', paymentDueDate.toIso8601String());

      // Clear all form fields and display success message
      _clean();
      _toastService.successToast('Sign up successful');

      // Navigate to the main page of the application
      _navigateToMainPage();
    } catch (e) {
      _toastService.errorToast('Failed to sign up');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to navigate to the main page of the application
  void _navigateToMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Main()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // Input field for user name
                      NormalInput(
                        placeholderText: 'User Name',
                        icon: Icons.person,
                        normalController: _userNameController,
                      ),
                      const SizedBox(height: 12.0),
                      // Input field for user mobile number
                      NumberInput(
                        placeholderText: 'Mobile Number',
                        icon: Icons.person,
                        normalController: _mobileNumberController,
                      ),
                      const SizedBox(height: 12.0),
                      // Input field for fitness center name
                      NormalInput(
                        placeholderText: 'Gym Name',
                        icon: Icons.person,
                        normalController: _gymNameController,
                      ),
                      const SizedBox(height: 12.0),
                      // Input field for fitness center address
                      NormalInput(
                        placeholderText: 'Gym Address',
                        icon: Icons.person,
                        normalController: _gymAddressController,
                      ),
                      const SizedBox(height: 36.0),
                      // Button to clear all form fields
                      NormalButton(buttonText: 'CLEAN', onPressed: _clean),
                      const SizedBox(height: 12.0),
                      // Button to register a gym
                      NormalButton(buttonText: 'SIGN UP', onPressed: _signUp),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
