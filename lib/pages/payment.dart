import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/payment_details.dart';
import 'package:gym_management/services/mongo_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final Future<void> _initializationFuture;
  late final PaymentDetails paymentDetails;
  late final String paymentDueDate;

  // Services for database operations and displaying toast messages
  final MongoService _mongoService = MongoService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializePaymentDetails();
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

  Future<void> _makePayment() async {}

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
            automaticallyImplyLeading: false,
            title: const Text(
              'Payment Page',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: FutureBuilder(
            future: _initializationFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Due Date:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                paymentDueDate.substring(0, 10),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2.0),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Amount:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'LKR ${paymentDetails.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        NormalButton(
                          buttonText: 'Make Payment',
                          onPressed: _makePayment,
                        ),
                      ],
                    ),
                  );
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}
