import 'package:flutter/material.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/date_input.dart';
import 'package:gym_management/widgets/normal_button.dart';
import 'package:gym_management/widgets/normal_input.dart';
import 'package:gym_management/widgets/number_input.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();

  void _clean() {
    _userNameController.clear();
    _ageController.clear();
    _startDateController.clear();
    _paymentDateController.clear();
  }

  Future<void> _create() async {
    if (_userNameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty &&
        _paymentDateController.text.isNotEmpty) {
      Member member = Member(
        name: _userNameController.text,
        age: int.parse(_ageController.text),
        startDate: _startDateController.text,
        paymentDate: _paymentDateController.text,
      );

      await _hiveService.addMember(member);
      _toastService.successToast('member added successfully');
      Main.of(context)?.navigate(1);
    } else {
      _toastService.warningToast('please fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
            NormalInput(
              placeholderText: 'Name',
              icon: Icons.person,
              normalController: _userNameController,
            ),
            const SizedBox(height: 12.0),
            NumberInput(
              placeholderText: 'Age',
              icon: Icons.cake_rounded,
              normalController: _ageController,
            ),
            const SizedBox(height: 12.0),
            DateInput(
              placeholderText: 'Start Date',
              icon: Icons.calendar_view_day_rounded,
              dateController: _startDateController,
            ),
            const SizedBox(height: 12.0),
            DateInput(
              placeholderText: 'Payment Date',
              icon: Icons.calendar_view_day_rounded,
              dateController: _paymentDateController,
            ),
            const SizedBox(height: 36.0),
            NormalButton(buttonText: 'CLEAN', onPressed: _clean),
            const SizedBox(height: 12.0),
            NormalButton(buttonText: 'INSERT', onPressed: _create),
          ],
        ),
      ),
    );
  }
}
