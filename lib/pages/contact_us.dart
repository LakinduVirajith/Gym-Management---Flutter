import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_text_area.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late final TextEditingController _messageController;
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _clean() {
    _messageController.clear();
  }

  Future<void> _sendFeedback() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      _toastService.warningToast('Please fill in the message field');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userName = prefs.getString('user_name');
      final String? mobileNumber = prefs.getString('mobile_number');

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'user_name': userName,
        'mobile_number': mobileNumber,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      _clean();
      _toastService.successToast('Feedback sent successfully');
    } catch (e) {
      _toastService.errorToast('Failed to send feedback');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'vp.code.labs@gmail.com',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _toastService
          .errorToast('Could not launch email app. Please try manually.');
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+94772780771',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _toastService
          .errorToast('Could not launch phone dialer. Please try manually.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            children: [
              const SizedBox(height: 24.0),
              const Text(
                'Company Information',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/company_logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 18.0),
              _infoTile(
                label: 'Email: vp.code.labs@gmail.com',
                icon: Icons.send,
                onPressed: _sendEmail,
              ),
              const SizedBox(height: 12.0),
              _infoTile(
                label: 'Mobile: +94 77 278 0771',
                icon: Icons.call,
                onPressed: _makePhoneCall,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Contact Us',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12.0),
              NormalTextArea(
                placeholderText:
                    "Your feedback is valuable to us! Help us improve our service by sharing your thoughts or suggesting new features.",
                normalController: _messageController,
              ),
              const SizedBox(height: 18.0),
              NormalButton(buttonText: 'CLEAN', onPressed: _clean),
              const SizedBox(height: 12.0),
              NormalButton(buttonText: 'SEND', onPressed: _sendFeedback),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 12.0, right: 4.0),
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.black87),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label)),
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
