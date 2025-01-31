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
  late final TextEditingController _userNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _startDateController;

  // Services for database operations and displaying toast messages
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _ageController = TextEditingController();
    _startDateController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _ageController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

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
        _toastService.successToast('Member added successfully');

        // Navigate to the list page of members
        _updateSelectedTabIndex(1);
      } catch (e) {
        _toastService.errorToast('Failed to add member');
      }
    } else {
      _toastService.warningToast('Please fill in all fields');
    }
  }

  // Method to update the selected bottom navigation tab index in the Main widget
  void _updateSelectedTabIndex(int index) {
    Main.of(context)?.navigate(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
      ),
    );
  }
}
