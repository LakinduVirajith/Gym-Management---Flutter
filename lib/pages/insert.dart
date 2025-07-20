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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _heightInCmController = TextEditingController();
  final TextEditingController _weightInKgController = TextEditingController();
  final TextEditingController _fitnessGoalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _membershipStartController =
      TextEditingController();

  final _authService = AuthService();
  final _toastService = ToastService();

  void _clean() {
    _fullNameController.clear();
    _dateOfBirthController.clear();
    _heightInCmController.clear();
    _weightInKgController.clear();
    _fitnessGoalController.clear();
    _notesController.clear();
    _membershipStartController.clear();
  }

  Future<void> _insertMember() async {
    final fullName = _fullNameController.text.trim();
    final dateOfBirth = _dateOfBirthController.text.trim();
    final heightInCm = _heightInCmController.text.trim();
    final weightInKg = _weightInKgController.text.trim();
    final fitnessGoal = _fitnessGoalController.text.trim();
    final notes = _notesController.text.trim();
    final membershipStart = _membershipStartController.text.trim();

    if (fullName.isEmpty ||
        dateOfBirth.isEmpty ||
        heightInCm.isEmpty ||
        weightInKg.isEmpty ||
        fitnessGoal.isEmpty ||
        membershipStart.isEmpty) {
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

      // GET THE CURRENT YEAR AND EXTRACT LAST TWO DIGITS
      final now = DateTime.now();
      final yearSuffix = now.year.toString().substring(2);

      // GET ALL MEMBERS
      final snapshot = await memberCollection.get();
      String newCustomId;

      final ids = snapshot.docs.map((doc) => doc.id).toList();

      // FILTER ONLY CURRENT YEAR IDS
      final currentYearIds =
          ids.where((id) => id.contains('-$yearSuffix-')).toList();

      if (currentYearIds.isNotEmpty) {
        final maxNumber = currentYearIds.map((id) {
          final parts = id.split('-');
          if (parts.length >= 3) {
            return int.tryParse(parts.last) ?? 0;
          }
          return 0;
        }).fold(0, (a, b) => a > b ? a : b);

        final nextNumber = maxNumber + 1;
        newCustomId =
            'MEM-$yearSuffix-${nextNumber.toString().padLeft(4, '0')}';
      } else {
        newCustomId = 'MEM-$yearSuffix-0001';
      }

      final dateFormatter = DateFormat('yyyy-MM-dd');
      final startDate = DateTime.parse(membershipStart);
      final nextPaymentDueDate = AppDateUtils.addOneMonth(startDate);

      await memberCollection.doc(newCustomId).set({
        'fullName': fullName,
        'dateOfBirth': dateFormatter.format(DateTime.parse(dateOfBirth)),
        'heightInCm': double.parse(heightInCm),
        'weightInKg': double.parse(weightInKg),
        'fitnessGoal': fitnessGoal,
        'notes': notes,
        'membershipStart': dateFormatter.format(startDate),
        'nextPaymentDue': dateFormatter.format(nextPaymentDueDate),
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
              const Center(
                child: Text(
                  '🏋️ Register New Member',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),
              NormalInput(
                placeholderText: 'Full Name',
                icon: Icons.person,
                normalController: _fullNameController,
              ),
              const SizedBox(height: 12.0),
              DateInput(
                placeholderText: 'Date of Birth',
                icon: Icons.cake,
                dateController: _dateOfBirthController,
              ),
              const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: 'Height (cm)',
                icon: Icons.height,
                normalController: _heightInCmController,
              ),
              const SizedBox(height: 12.0),
              NumberInput(
                placeholderText: 'Weight (kg)',
                icon: Icons.monitor_weight,
                normalController: _weightInKgController,
              ),
              const SizedBox(height: 12.0),
              NormalInput(
                placeholderText: 'Fitness Goal',
                icon: Icons.flag,
                normalController: _fitnessGoalController,
              ),
              const SizedBox(height: 12.0),
              NormalInput(
                placeholderText: 'Notes (optional)',
                icon: Icons.note,
                normalController: _notesController,
              ),
              const SizedBox(height: 12.0),
              DateInput(
                placeholderText: 'Membership Starts',
                icon: Icons.calendar_today,
                dateController: _membershipStartController,
              ),
              const SizedBox(height: 36.0),
              NormalButton(
                buttonText: 'CLEAN',
                onPressed: _clean,
              ),
              const SizedBox(height: 12.0),
              NormalButton(
                buttonText: 'INSERT',
                onPressed: _insertMember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
