import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
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
          id: doc.id,
          name: data['name'] ?? '',
          startDate: data['startDate'] ?? '',
          nextPayment: data['nextPayment'] ?? '',
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

  Future<void> _updateMemberPaymentDate(Member member) async {
    final currentUser = _authService.currentUser;

    DateTime newPaymentDate =
        AppDateUtils.addOneMonth(DateTime.parse(member.nextPayment));
    String formattedDate = DateFormat('yyyy-MM-dd').format(newPaymentDate);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('members')
          .doc(member.id)
          .update({'nextPayment': formattedDate});

      _toastService.successToast('🎉 Member payment updated successfully');
    } catch (e) {
      _toastService.errorToast('❗Failed to update member payment');
    } finally {
      // REFRESH LIST AFTER UPDATE
      await _fetchMembers();
    }
  }

  void _showConfirmationDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Payment Confirmation',
            message:
                'Are you sure you want to confirm ${member.name}\'s payment?',
            option1: 'No',
            option2: 'Yes',
          ),
          onConfirm: () {
            Navigator.pop(context);
            _updateMemberPaymentDate(member);
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
      return const Center(child: Text('No members to show.'));
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
                'Due Payments',
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
                'Up-to-Date Payments',
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
                    'ID:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Name:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Start:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Payment:',
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
                    member.id,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    member.name,
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
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.black,
              ),
              child: IconButton(
                icon: const Icon(Icons.done),
                color: Colors.white,
                onPressed: () => _showConfirmationDialog(context, member),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
