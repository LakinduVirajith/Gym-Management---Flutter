import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/dialog_utils.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';
import 'package:gym_management/widgets/password_input.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _toastService = ToastService();

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _toastService.warningToast('⚠️ Please enter both email and password');
      return;
    }

    try {
      setState(() => _isLoading = true);

      // ATTEMPT SIGN IN
      final UserCredential userCred = await _authService.signIn(
        email,
        password,
      );
      final user = userCred.user;

      if (user == null) {
        _toastService.errorToast('❗ Failed to retrieve user.');
        return;
      }

      if (!user.emailVerified) {
        await showEmailNotVerifiedDialog(context, user);
        return;
      }

      // FETCH USER DOCUMENT
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        _toastService.errorToast('🚫 User record not found in Database.');
        return;
      }

      final userData = userDoc.data()!;

      // SAVE LOCAL VARIABLES
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_start_date', userData['appStartDate'] ?? '');
      await prefs.setString(
          'payment_due_date', userData['paymentDueDate'] ?? '');

      // UPFDATE LAST-ACTIVEDATE IN FIRESTORE
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await userRef.update({
        'lastActiveDate': today,
      });

      _toastService.successToast('✅ Login successful!');
      _navigateToMainPage();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = '👤 No user found with this email.';
          break;
        case 'wrong-password':
          message = '🔐 Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = '✉️ Invalid email address format.';
          break;
        case 'invalid-credential':
          message = '❌ Invalid login credentials.';
          break;
        case 'user-disabled':
          message = '🚫 This account has been disabled.';
          break;
        case 'too-many-requests':
          message = '⚠️ Too many login attempts. Please wait and try again.';
          break;
        default:
          message = '❗ Login failed: ${e.message ?? 'Unknown error.'}';
          break;
      }
      _toastService.errorToast(message);
    } catch (e) {
      _toastService.errorToast('❗ Unexpected error occurred during login.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final forgotEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: NormalInput(
          placeholderText: 'Enter your email',
          icon: Icons.email,
          normalController: forgotEmailController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = forgotEmailController.text.trim();
              if (email.isEmpty) {
                _toastService.warningToast('⚠️ Please enter your email.');
                return;
              }
              try {
                await _authService.sendPasswordResetEmail(email);
                Navigator.pop(context);

                _toastService
                    .successToast('✅ Password reset email sent successfully!');
              } on FirebaseAuthException catch (e) {
                String errorMsg = '❌ Failed to send password reset email.';
                switch (e.code) {
                  case 'user-not-found':
                    errorMsg = '👤 No user found with this email address.';
                    break;
                  case 'invalid-email':
                    errorMsg = '✉️ Invalid email address format.';
                    break;
                  case 'too-many-requests':
                    errorMsg =
                        '⚠️ Too many requests. Please wait and try again later.';
                    break;
                  default:
                    errorMsg = '❗ ${e.message ?? "Unknown error occurred."}';
                }
                _toastService.errorToast(errorMsg);
              } catch (_) {
                _toastService
                    .errorToast('❗ Unexpected error. Please try again.');
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMainPage() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/main', (Route<dynamic> route) => false);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset('assets/application_logo.png'),
                  ),
                ),
                const SizedBox(height: 36.0),
                NormalInput(
                  placeholderText: 'Email',
                  icon: Icons.email,
                  normalController: _emailController,
                ),
                const SizedBox(height: 12.0),
                PasswordInput(
                  placeholderText: 'Password',
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 36.0),
                NormalButton(
                  buttonText: _isLoading ? 'Logging in...' : 'LOGIN',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 18.0),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/signup',
                              (Route<dynamic> route) => false,
                            );
                          },
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
