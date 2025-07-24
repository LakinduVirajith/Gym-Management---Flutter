import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/utils/dialog_utils.dart';
import 'package:gym_management/validators/sign_up_validators.dart';
import 'package:gym_management/widgets/intl_phone_field.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';
import 'package:gym_management/widgets/password_input.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _gymNameController = TextEditingController();
  final _gymAddressController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  final _toastService = ToastService();
  String _fullMobileNumber = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _gymNameController.dispose();
    _gymAddressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clean() {
    _emailController.clear();
    _mobileNumberController.clear();
    _gymNameController.clear();
    _gymAddressController.clear();
    _passwordController.clear();
    _fullMobileNumber = '';
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final mobileNumber = _fullMobileNumber.trim();
    final gymName = _gymNameController.text.trim();
    final gymAddress = _gymAddressController.text.trim();
    final password = _passwordController.text.trim();

    // VALIDATE INPUTS
    final emailError = SignUpValidators.validateEmail(email);
    final mobileError = SignUpValidators.validateMobileNumber(mobileNumber);
    final nameError = SignUpValidators.validateFitnessCenterName(gymName);
    final addressError =
        SignUpValidators.validateFitnessCenterAddress(gymAddress);
    final passError = SignUpValidators.validatePassword(password);

    final errorMessage =
        emailError ?? nameError ?? mobileError ?? addressError ?? passError;

    if (errorMessage != null) {
      _toastService.warningToast(errorMessage);
      return;
    }

    final dateFormatter = DateFormat('yyyy-MM-dd');
    final appStartDate = DateTime.now();
    final paymentDueDate = AppDateUtils.addMonths(appStartDate, 1);

    try {
      setState(() => _isLoading = true);

      // REGISTER USER IN FIREBASE AUTH
      final userCred = await _authService.signUp(email, password);
      final uid = userCred.user!.uid;
      await userCred.user!.sendEmailVerification();

      // SAVE USER PROFILE DATA
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'mobileNumber': mobileNumber,
        'gymName': gymName,
        'gymAddress': gymAddress,
        'appStartDate': dateFormatter.format(appStartDate),
        'paymentDueDate': dateFormatter.format(paymentDueDate),
        'lastActiveDate': dateFormatter.format(appStartDate),
      });

      // SAVE TO SHARED-PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_start_date', appStartDate.toIso8601String());
      await prefs.setString(
          'payment_due_date', paymentDueDate.toIso8601String());

      _toastService.successToast('✅ Sign up successful!');
      await showEmailVerificationDialog(context);
      _clean();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = '🚫 This email is already associated with an account.';
          break;
        case 'invalid-email':
          message = '✉️ Invalid email address format.';
          break;
        case 'weak-password':
          message = '🔐 Password is too weak. Please choose a stronger one.';
          break;
        case 'too-many-requests':
          message = '⚠️ Too many attempts. Try again later.';
          break;
        default:
          message = '❗ Sign up failed: ${e.message ?? 'Unknown error.'}';
          break;
      }
      _toastService.errorToast(message);
    } catch (e) {
      _toastService.errorToast('❗ Unexpected error occurred during sign up.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) showExitConfirmation(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24.0),
                NormalInput(
                  placeholderText: 'Email (User Name)',
                  icon: Icons.email,
                  normalController: _emailController,
                ),
                const SizedBox(height: 12.0),
                CustomIntlPhoneField(
                  placeholderText: 'Mobile Number',
                  controller: _mobileNumberController,
                  onChanged: (val) {
                    _fullMobileNumber = val;
                  },
                  initialCountryCode: 'LK',
                ),
                const SizedBox(height: 12.0),
                NormalInput(
                  placeholderText: 'Fitness Center Name',
                  icon: Icons.fitness_center,
                  normalController: _gymNameController,
                ),
                const SizedBox(height: 12.0),
                NormalInput(
                  placeholderText: 'Fitness Center Address',
                  icon: Icons.location_on,
                  normalController: _gymAddressController,
                ),
                const SizedBox(height: 12.0),
                PasswordInput(
                  placeholderText: 'Password',
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 36.0),
                NormalButton(
                  buttonText: 'CLEAN',
                  onPressed: _clean,
                ),
                const SizedBox(height: 12.0),
                NormalButton(
                  buttonText: _isLoading ? 'Please wait...' : 'SIGN UP',
                  onPressed: _isLoading ? null : _signUp,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 18.0),
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
