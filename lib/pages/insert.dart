import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/services/auth_service.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();

  final _authService = AuthService();
  final _toastService = ToastService();

  void _clean() {
    _nameController.clear();
    _birthDayController.clear();
    _heightController.clear();
    _weightController.clear();
    _goalController.clear();
    _remarksController.clear();
    _startDateController.clear();
  }

  Future<void> _insertMember() async {
    final name = _nameController.text.trim();
    final birthDay = _birthDayController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final goal = _goalController.text.trim();
    final remarks = _remarksController.text.trim();
    final startDateText = _startDateController.text.trim();

    if (name.isEmpty ||
        birthDay.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        goal.isEmpty ||
        startDateText.isEmpty) {
      _toastService.warningToast("⚠️ Please fill in all required fields.");
      return;
    }

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _toastService
            .warningToast("⚠️ Your session has expired. Please log in again.");

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      final memberCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('members');

      // GET THE LATEST MEMBER ID AND GENERATE NEW ID
      final snapshot = await memberCollection.get();
      String newCustomId;

      if (snapshot.docs.isNotEmpty) {
        final ids = snapshot.docs.map((doc) => doc.id).toList();

        final maxNumber = ids.map((id) {
          final parts = id.split('_');
          if (parts.length == 2) {
            return int.tryParse(parts[1]) ?? 0;
          }
          return 0;
        }).reduce((a, b) => a > b ? a : b);

        final nextId = maxNumber + 1;
        newCustomId = 'M-${nextId.toString().padLeft(4, '0')}';
      } else {
        newCustomId = 'M-0001';
      }

      final dateFormatter = DateFormat('yyyy-MM-dd');
      final startDate = DateTime.parse(startDateText);
      final nextPaymentDate = AppDateUtils.addOneMonth(startDate);

      await memberCollection.doc(newCustomId).set({
        'name': name,
        'birthday': dateFormatter.format(DateTime.parse(birthDay)),
        'height': double.parse(height),
        'weight': double.parse(weight),
        'goal': goal,
        'remarks': remarks,
        'startDate': dateFormatter.format(startDate),
        'nextPayment': dateFormatter.format(nextPaymentDate),
        'createdAt': dateFormatter.format(DateTime.now()),
      });

      _toastService.successToast("✅ Member has been added successfully!");
      _navigateToMainPage();
      _clean();
    } catch (e) {
      _toastService.errorToast("❌ Failed to add member. Please try again.");
    }
  }

  void _navigateToMainPage() {
    Main.of(context)?.navigate(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              const Text(
                'New Member',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24.0),
              NormalInput(
                  placeholderText: 'Name',
                  icon: Icons.person,
                  normalController: _nameController),
              const SizedBox(height: 12.0),
              DateInput(
                placeholderText: 'BirthDay',
                icon: Icons.cake,
                dateController: _birthDayController,
              ),
              const SizedBox(height: 12.0),
              NumberInput(
                  placeholderText: 'Height (cm)',
                  icon: Icons.height,
                  normalController: _heightController),
              const SizedBox(height: 12.0),
              NumberInput(
                  placeholderText: 'Weight (kg)',
                  icon: Icons.monitor_weight,
                  normalController: _weightController),
              const SizedBox(height: 12.0),
              NormalInput(
                  placeholderText: 'Goal',
                  icon: Icons.flag,
                  normalController: _goalController),
              const SizedBox(height: 12.0),
              NormalInput(
                  placeholderText: 'Remarks (optional)',
                  icon: Icons.note,
                  normalController: _remarksController),
              const SizedBox(height: 12.0),
              DateInput(
                  placeholderText: 'Start Date',
                  icon: Icons.calendar_today,
                  dateController: _startDateController),
              const SizedBox(height: 36.0),
              NormalButton(buttonText: 'CLEAN', onPressed: _clean),
              const SizedBox(height: 12.0),
              NormalButton(buttonText: 'INSERT', onPressed: _insertMember),
            ],
          ),
        ),
      ),
    );
  }
}
