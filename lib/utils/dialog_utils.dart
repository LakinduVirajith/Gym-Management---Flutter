import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';

final AuthService _authService = AuthService();
final ToastService _toastService = ToastService();

/// SHOWS A CONFIRMATION DIALOG WHEN THE USER ATTEMPTS TO EXIT THE APP
void showExitConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => ConfirmationDialog(
      confirmationMessage: ConfirmationMessage(
        topic: 'Exit Application',
        message: 'Are you sure you want to exit the application?',
        option1: 'No',
        option2: 'Yes',
      ),
      onConfirm: () => SystemNavigator.pop(),
    ),
  );
}

/// SHOWS A DIALOG AFTER SUCCESSFUL SIGN UP ASKING THE USER TO VERIFY THEIR EMAIL
Future<void> showEmailVerificationDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('📩 Verify Your Email'),
      content: const Text(
        'We have sent a verification link to your email.\nPlease verify to activate your account.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            const gmailUrl = 'https://mail.google.com/';
            if (await canLaunchUrl(Uri.parse(gmailUrl))) {
              await launchUrl(Uri.parse(gmailUrl),
                  mode: LaunchMode.externalApplication);
            } else {
              _toastService.errorToast("❌ Couldn't open Gmail.");
            }
          },
          child: const Text(
            'Open Gmail',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

/// SHOWS A DIALOG IF THE USER TRIES TO LOGIN WITHOUT VERIFYING THEIR EMAIL
Future<void> showEmailNotVerifiedDialog(BuildContext context, User user) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('📩 Email Not Verified'),
      content: const Text(
        'Your email is not verified yet. Please check your inbox or resend the verification link.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Back',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              await user.sendEmailVerification();
              Navigator.pop(context);
              _toastService.successToast('✅ Verification email sent again!');
            } catch (e) {
              Navigator.pop(context);
              _toastService.errorToast('❌ Failed to send verification email.');
            }
          },
          child: const Text(
            'Resend Email',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

/// SHOW THE DIALOG FOR SETTING GYM PAYMENT PLANS.
Future<void> showInitialSetupDialog(BuildContext context) async {
  final TextEditingController oneMonthController = TextEditingController();
  final TextEditingController threeMonthController = TextEditingController();
  final TextEditingController sixMonthController = TextEditingController();
  final TextEditingController oneYearController = TextEditingController();

  final user = _authService.currentUser;
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

  final plans = doc.data()?['paymentPlans']?? {};
  final currentValues = {
    '1month': (plans['1month'] is num)
        ? (plans['1month'] as num).toInt().toString()
        : null,
    '3months': (plans['3months'] is num)
        ? (plans['3months'] as num).toInt().toString()
        : null,
    '6months': (plans['6months'] is num)
        ? (plans['6months'] as num).toInt().toString()
        : null,
    '1year': (plans['1year'] is num)
        ? (plans['1year'] as num).toInt().toString()
        : null,
  };

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          '🏋️ Set Gym Payment Plans',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Required Plan',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: "1 Month Plan Amount (Required)",
                icon: Icons.payment_rounded,
                normalController: oneMonthController,
              ),
              currentValues['1month'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        top: 2.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        'Current Plan: ${currentValues['1month']}',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(height: 12.0),
              const Text(
                'Optional Plans',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: "3 Months Plan Amount (Optional)",
                icon: Icons.payment_rounded,
                normalController: threeMonthController,
              ),
              currentValues['3months'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        top: 2.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        'Current Plan: ${currentValues['3months']}',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: "6 Months Plan Amount (Optional)",
                icon: Icons.payment_rounded,
                normalController: sixMonthController,
              ),
              currentValues['6months'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        top: 2.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        'Current Plan: ${currentValues['6months']}',
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: "1 Year Plan Amount (Optional)",
                icon: Icons.payment_rounded,
                normalController: oneYearController,
              ),
              if (currentValues['1year'] != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4.0,
                    top: 2.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    'Current Plan: ${currentValues['1year']}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oneMonthController.text.trim().isEmpty) {
                _toastService
                    .warningToast('⚠️ Please enter the 1 Month plan amount');
                return;
              }

              Map<String, double> plansData = {
                '1month': double.parse(oneMonthController.text.trim()),
              };
              if (threeMonthController.text.trim().isNotEmpty) {
                plansData['3months'] =
                    double.parse(threeMonthController.text.trim());
              }
              if (sixMonthController.text.trim().isNotEmpty) {
                plansData['6months'] =
                    double.parse(sixMonthController.text.trim());
              }
              if (oneYearController.text.trim().isNotEmpty) {
                plansData['1year'] =
                    double.parse(oneYearController.text.trim());
              }

              final currentUser = _authService.currentUser;
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.uid)
                    .set(
                  {'paymentPlans': plansData},
                  SetOptions(merge: true),
                );

                _toastService.successToast('✅ Payment plans saved!');
                Navigator.pop(context);
              } catch (e) {
                _toastService
                    .errorToast('❌ Failed to save payment plans. Try again.');
              }
            },
            child: const Text(
              'Save Plans',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    },
  );
}
