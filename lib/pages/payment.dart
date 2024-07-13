import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/payment_details.dart';
import 'package:gym_management/services/mongo_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final PaymentDetails paymentDetails;
  late final String paymentDueDate;

  // Services for database operations and displaying toast messages
  final MongoService _mongoService = MongoService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    _initializePaymentDetails();
  }

  @override
  void dispose() {
    // Disconnect from the MongoDB database and dispose of controllers
    _mongoService.disconnect();
    super.dispose();
  }

  // Method to initialize payment details
  Future<void> _initializePaymentDetails() async {
    try {
      await _mongoService.connect();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      paymentDueDate = prefs.getString('payment_due_date') ?? '';

      if (paymentDueDate.isEmpty) {
        _toastService.errorToast("Failed to load payment due date.");
      }

      final details = await _mongoService.getPaymentDetails();
      if (details != null) {
        paymentDetails = PaymentDetails.fromJson(details);
      } else {
        _toastService.errorToast("Failed to load payment details.");
      }
    } catch (e) {
      _toastService.errorToast("Failed to load payment details.");
    }
  }

  // Show a confirmation dialog before exiting the application
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Exit Application',
            message: 'Are you sure you want to exit the application?',
            option1: 'No',
            option2: 'Yes',
          ),
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return; // Disable default back action
        _showExitConfirmation(
            context); // Show exit confirmation dialog when back button is pressed
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Payment Page'),
          ),
          body: FutureBuilder(
            future: _initializePaymentDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Error loading payment details'));
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Amount: LKR ${paymentDetails.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Payment Due Date: $paymentDueDate',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Implement payment logic here
                        },
                        child: const Text('Make Payment'),
                      ),
                    ],
                  ),
                );
              }
            },
          )),
    );
  }
}
