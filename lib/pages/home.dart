import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/utils/dialog_utils.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _toastService = ToastService();

  List<Member> _allMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _toastService
            .warningToast("⚠️ Your session has expired. Please log in again.");

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('members')
          .get();

      final members = querySnapshot.docs.map((doc) {
        final data = doc.data();

        return Member(
          fireID: doc.id,
          fullName: data['fullName'] ?? '',
          gender: data['gender'] ?? '',
          startDate: data['membershipStart'] ?? '',
          nextPayment: data['nextPaymentDue'] ?? '',
          subscriptionPlan: data['subscriptionPlan'] ?? '',
        );
      }).toList();

      members.sort((a, b) {
        DateTime aPaymentDate = DateTime.parse(a.nextPayment);
        DateTime bPaymentDate = DateTime.parse(b.nextPayment);
        return aPaymentDate.compareTo(bPaymentDate);
      });

      setState(() {
        _allMembers = members;
      });
    } catch (e) {
      _toastService.errorToast("❌ Failed to load members. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMemberPaymentDate(Member member, DateTime newDate) async {
    final currentUser = _authService.currentUser;
    String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('members')
          .doc(member.fireID)
          .update({'nextPaymentDue': formattedDate});

      _toastService.successToast('🎉 Payment date updated successfully');
    } catch (e) {
      _toastService.errorToast('❗Failed to update payment date');
    } finally {
      // REFRESH LIST AFTER UPDATE
      await _fetchMembers();
    }
  }

  void _showPaymentConfirmationDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: '💵 Payment Confirmation',
            message:
                'Are you sure you want to mark ${member.fullName}\'s (${member.fireID}) payment as received?',
            option1: 'Cancel',
            option2: 'Confirm',
          ),
          onConfirm: () async {
            final currentPaymentDate = DateTime.parse(member.nextPayment);
            int monthsToAdd =
                AppDateUtils.getMonthsFromPlan(member.subscriptionPlan);
            final newPaymentDate =
                AppDateUtils.addMonths(currentPaymentDate, monthsToAdd);

            await _updateMemberPaymentDate(member, newPaymentDate);
            if (mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditDueDateDialog(BuildContext context, Member member) {
    DateTime currentDueDate = DateTime.parse(member.nextPayment);
    DateTime selectedDate = currentDueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                '🗓️ Edit Next Payment Due Date',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    'Current Due Date: ${DateFormat('yyyy-MM-dd').format(currentDueDate)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'New Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.calendar_today_sharp,
                      color: Colors.black,
                      size: 18.0,
                    ),
                    label: const Text(
                      'Pick New Date',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateMemberPaymentDate(member, selectedDate);
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allMembers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'No gym members yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your first gym member to start tracking progress and payments.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.add_card,
                  color: Colors.black,
                ),
                label: const Text(
                  'Setup Payment Plans',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () => showInitialSetupDialog(context),
              ),
            ],
          ),
        ),
      );
    }

    DateTime now = DateTime.now();

    List<Member> duePayments = _allMembers
        .where((m) => DateTime.parse(m.nextPayment).isBefore(now))
        .toList();
    List<Member> upToDatePayments = _allMembers
        .where((m) => !DateTime.parse(m.nextPayment).isBefore(now))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: const Text(
                '⏰ Due Payments',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: duePayments.length,
                itemBuilder: (context, index) =>
                    _buildMemberItem(context, duePayments[index]),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: const Text(
                '🗒️ Up-to-Date Payments',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: upToDatePayments.length,
                itemBuilder: (context, index) =>
                    _buildMemberItem(context, upToDatePayments[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, Member member) {
    DateTime paymentDate = DateTime.parse(member.nextPayment);
    bool isDue = paymentDate.isBefore(DateTime.now());
    Color borderColor = isDue
        ? const Color.fromARGB(255, 255, 120, 110)
        : const Color.fromARGB(255, 100, 255, 115);

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member ID:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Full Name:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Membership Start:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Next Payment Due:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Subscription Plan:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fireID,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    member.fullName,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    member.startDate,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    member.nextPayment,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    member.subscriptionPlan,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  height: 42.0,
                  width: 42.0,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.black87,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.attach_money),
                    color: Colors.white,
                    iconSize: 20.0,
                    onPressed: () =>
                        _showPaymentConfirmationDialog(context, member),
                    tooltip: 'Payment Confirmation',
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  height: 42.0,
                  width: 42.0,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.black87,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    color: Colors.white,
                    iconSize: 20.0,
                    onPressed: () => _showEditDueDateDialog(context, member),
                    tooltip: 'Edit Payment Due Date',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
