import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';

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
