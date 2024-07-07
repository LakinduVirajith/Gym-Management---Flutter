import 'package:flutter/material.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/widgets/date_input.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';
import 'package:gym_management/widgets/number_input.dart';
import 'package:intl/intl.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  // TextEditingControllers for form fields
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  // Services for database operations and displaying toast messages
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();

  // Method to clear all form fields
  void _clean() {
    _userNameController.clear();
    _ageController.clear();
    _startDateController.clear();
  }

  // Method to create a new member
  Future<void> _create() async {
    if (_userNameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty) {
      // Parse start date and calculate next payment date
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime paymentDate = AppDateUtils.addOneMonth(startDate);
      String formattedPaymentDate =
          DateFormat('yyyy-MM-dd').format(paymentDate);

      // Create a new member object
      Member member = Member(
        name: _userNameController.text,
        age: int.parse(_ageController.text),
        startDate: _startDateController.text,
        nextPayment: formattedPaymentDate,
      );

      // Add the member to the Hive database
      try {
        await _hiveService.addMember(member);
        _toastService.successToast('member added successfully');

        // Navigate to the member list page
        Main.of(context)?.navigate(1);
      } catch (e) {
        _toastService.errorToast('failed to add member');
      }
    } else {
      _toastService.warningToast('please fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              const Text(
                'New Member',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24.0),
              // Input field for member's name
              NormalInput(
                placeholderText: 'Name',
                icon: Icons.person,
                normalController: _userNameController,
              ),
              const SizedBox(height: 12.0),
              // Input field for member's age
              NumberInput(
                placeholderText: 'Age',
                icon: Icons.cake_rounded,
                normalController: _ageController,
              ),
              const SizedBox(height: 12.0),
              // Input field for member's start date
              DateInput(
                placeholderText: 'Start Date',
                icon: Icons.calendar_view_day_rounded,
                dateController: _startDateController,
              ),
              const SizedBox(height: 36.0),
              // Button to clear all form fields
              NormalButton(buttonText: 'CLEAN', onPressed: _clean),
              const SizedBox(height: 12.0),
              // Button to create a new member
              NormalButton(buttonText: 'INSERT', onPressed: _create),
            ],
          ),
        ),
      ),
    );
  }
}
