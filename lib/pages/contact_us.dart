import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill in all the fields.")),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'alccodelab@gmail.com',
      query: Uri.encodeFull(
        'subject=Message from $name&body=From: $name\nEmail: $email\n\n$message',
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not open email app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // phone back button
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📞 Contact Us'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // app bar back
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "We're here to help!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "If you have any questions, feedback, or suggestions, feel free to reach out.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              NormalInput(
                placeholderText: 'Full Name',
                icon: Icons.person,
                normalController: _nameController,
              ),
              const SizedBox(height: 12),
              NormalInput(
                placeholderText: 'Email Address',
                icon: Icons.email,
                normalController: _emailController,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.message),
                  hintText: "Your message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: NormalButton(
                  buttonText: 'SEND MESSAGE',
                  onPressed: _sendEmail,
                ),
              ),
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 12),
              const Text("📍 Address: Gym HQ, Colombo, Sri Lanka"),
              const SizedBox(height: 6),
              const Text("📞 Phone: +94 71 123 4567"),
              const SizedBox(height: 6),
              const Text("✉️ Email: alccodelab@gmail.com"),
            ],
          ),
        ),
      ),
    );
  }
}
