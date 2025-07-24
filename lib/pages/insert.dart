import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_management/main.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/utils/dialog_utils.dart';
import 'package:gym_management/validators/insert_validators.dart';
import 'package:gym_management/validators/sign_up_validators.dart';
import 'package:gym_management/widgets/date_input.dart';
import 'package:gym_management/widgets/dropdown_input.dart';
import 'package:gym_management/widgets/intl_phone_field.dart';
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
  final TextEditingController _mobileNumberController = TextEditingController();

  final _authService = AuthService();
  final _toastService = ToastService();

  String _fullMobileNumber = '';
  Map<String, dynamic> _paymentPlanData = {};
  List<String> _planOptions = [];
  String? _selectedPlan;

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchUserPaymentPlans();
  }

  Future<void> _fetchUserPaymentPlans() async {
    final user = _authService.currentUser;
    if (user == null) {
      _toastService
          .warningToast("⚠️ Your session has expired. Please log in again.");

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final plans = doc.data()?['paymentPlans'];

    if (plans == null || (plans as Map).isEmpty) {
      _toastService
          .warningToast("⚠️ No payment plans found! Please set them up.");
      await showInitialSetupDialog(context);
      await _fetchUserPaymentPlans();
    } else {
      setState(() {
        _planOptions = plans.keys
            .map((key) => AppDateUtils.formatPlanLabel(key))
            .toList()
            .reversed
            .toList();
        if (_planOptions.isNotEmpty) {
          _selectedPlan = _planOptions.first;
        }
        _paymentPlanData = Map<String, dynamic>.from(plans);
      });
    }
  }

  Future<void> _insertMember() async {
    final fullName = _fullNameController.text.trim();
    final dateOfBirth = _dateOfBirthController.text.trim();
    final heightInCm = _heightInCmController.text.trim();
    final weightInKg = _weightInKgController.text.trim();
    final fitnessGoal = _fitnessGoalController.text.trim();
    final notes = _notesController.text.trim();
    final membershipStart = _membershipStartController.text.trim();
    final mobileNumber = _fullMobileNumber.trim();
    final selectedGender = _selectedGender;
    final selectedPlan = _selectedPlan;

    final nameError = InsertValidators.validateName(fullName);
    final dobError = InsertValidators.validateDateOfBirth(dateOfBirth);
    final heightError = InsertValidators.validateHeight(heightInCm);
    final weightError = InsertValidators.validateWeight(weightInKg);
    final goalError = InsertValidators.validateGoal(fitnessGoal);
    final startError =
        InsertValidators.validateMembershipStart(membershipStart);
    final mobileError = SignUpValidators.validateMobileNumber(mobileNumber);

    final genderError = selectedGender == null || selectedGender.isEmpty
        ? '⚧️ Please select a gender before continuing.'
        : null;
    final planError = selectedPlan == null || selectedPlan.isEmpty
        ? '📅 Please select a subscription plan'
        : null;

    final errorMessage = nameError ??
        genderError ??
        dobError ??
        heightError ??
        weightError ??
        goalError ??
        startError ??
        mobileError ??
        planError;

    if (errorMessage != null) {
      _toastService.warningToast("⚠️ $errorMessage");
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
      final ids = snapshot.docs.map((doc) => doc.id).toList();

      // FILTER ONLY CURRENT YEAR IDS
      final currentYearIds =
          ids.where((id) => id.contains('-$yearSuffix-')).toList();

      String newCustomId;
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

      int monthsToAdd = AppDateUtils.getMonthsFromPlan(selectedPlan!);
      final nextPaymentDueDate = AppDateUtils.addMonths(startDate, monthsToAdd);

      final rawPlanKey = _paymentPlanData.keys.firstWhere(
        (k) => AppDateUtils.formatPlanLabel(k) == selectedPlan,
        orElse: () => '',
      );
      final paymentAmount =
          rawPlanKey.isNotEmpty ? _paymentPlanData[rawPlanKey] ?? 0 : 0;

      await memberCollection.doc(newCustomId).set({
        'fullName': fullName,
        'gender': selectedGender,
        'dateOfBirth': dateFormatter.format(DateTime.parse(dateOfBirth)),
        'heightInCm': double.parse(heightInCm),
        'weightInKg': double.parse(weightInKg),
        'fitnessGoal': fitnessGoal,
        'notes': notes,
        'membershipStart': dateFormatter.format(startDate),
        'nextPaymentDue': dateFormatter.format(nextPaymentDueDate),
        'subscriptionPlan': selectedPlan,
        'createdAt': dateFormatter.format(DateTime.now()),
        'mobileNumber': _fullMobileNumber,
        'totalPaid': paymentAmount,
      });

      _toastService.successToast("✅ Member has been added successfully!");
      _navigateToMainPage();
      _clean();
    } catch (e) {
      _toastService.errorToast("❌ Failed to add member. Please try again.");
    }
  }

  void _clean() {
    _fullNameController.clear();
    _dateOfBirthController.clear();
    _heightInCmController.clear();
    _weightInKgController.clear();
    _fitnessGoalController.clear();
    _notesController.clear();
    _membershipStartController.clear();
    _mobileNumberController.clear();
    _fullMobileNumber = '';
  }

  void _navigateToMainPage() {
    Main.of(context)?.navigate(1);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _heightInCmController.dispose();
    _weightInKgController.dispose();
    _fitnessGoalController.dispose();
    _notesController.dispose();
    _membershipStartController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
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
              DropdownInput(
                hintText: 'Select Gender',
                selectedItem: _selectedGender,
                itemOptions: _genderOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
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
              const SizedBox(height: 12.0),
              DropdownInput(
                hintText: 'Select Payment Plan',
                selectedItem: _selectedPlan,
                itemOptions: _planOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedPlan = value;
                  });
                },
              ),
              const SizedBox(height: 12.0),
              CustomIntlPhoneField(
                placeholderText: 'Mobile Number',
                controller: _mobileNumberController,
                onChanged: (val) {
                  _fullMobileNumber = val;
                },
                initialCountryCode: 'LK',
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
