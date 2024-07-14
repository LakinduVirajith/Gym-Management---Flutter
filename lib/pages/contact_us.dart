import 'package:flutter/material.dart';
import 'package:gym_management/services/mongo_service.dart';
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
  // TextEditingControllers for form fields
  late final TextEditingController _messageController;

  // Services for database operations and displaying toast messages
  final MongoService _mongoService = MongoService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    // Connect to the MongoDB database on initialization
    _mongoService.connect();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    // Disconnect from the MongoDB database and dispose of controllers
    _mongoService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  // Method to clear the message field
  void _clean() {
    _messageController.clear();
  }

  // Method to send user feedback to the MongoDB database.
  Future<void> _sendFeedback() async {
    final String message = _messageController.text.trim();

    // Check if message field is filled
    if (message.isEmpty) {
      _toastService.warningToast('Please fill in the message field');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Insert user feedback into the database
      await _mongoService.insertFeedback({
        'user_name': prefs.getString('user_name'),
        'mobile_number': prefs.getString('mobile_number'),
        'message': message
      });

      // Clear form field and display success message
      _clean();
      _toastService.successToast('Feedback sent successfully');
    } catch (e) {
      _toastService.errorToast('Failed to send feedback');
    }
  }

  // Method to launch the email app with a prefilled email address
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

  // Method to launch the phone dialer with a prefilled phone number
  void _makePhoneCall() async {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              children: [
                const SizedBox(height: 24.0),
                const Text(
                  'Compnay Informations',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18.0),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/company_logo.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Container(
                  padding: const EdgeInsets.only(left: 12.0, right: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.black87,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text('Email: vp.code.labs@gmail.com'),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: _sendEmail,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.only(left: 12.0, right: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.black87,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text('Mobile: +94 77 278 0771'),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          onPressed: _makePhoneCall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12.0),
                NormalTextArea(
                    placeholderText:
                        "Your feedback is valuable to us! Help us improve our service by sharing your thoughts or suggesting new features.",
                    normalController: _messageController),
                const SizedBox(height: 18.0),
                NormalButton(buttonText: 'CLEAN', onPressed: _clean),
                const SizedBox(height: 12.0),
                NormalButton(buttonText: 'SEND', onPressed: _sendFeedback)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
