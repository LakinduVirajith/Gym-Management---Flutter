import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();
  List<Member> _allMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch members when the widget is first created
    _getMembers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Fetch members from the Hive database and sort them by payment date
  Future<void> _getMembers() async {
    List<Member> members = _hiveService.getMembers();

    members.sort((a, b) {
      DateTime aPaymentDate = DateTime.parse(a.nextPayment);
      DateTime bPaymentDate = DateTime.parse(b.nextPayment);
      return aPaymentDate.compareTo(bPaymentDate);
    });

    setState(() {
      _allMembers = members;
      _isLoading = false;
    });
  }

  // Update the member's payment date and notify the user
  void _updateMember(Member member) async {
    DateTime paymentDate =
        AppDateUtils.addOneMonth(DateTime.parse(member.nextPayment));
    String formattedPaymentDate = DateFormat('yyyy-MM-dd').format(paymentDate);
    member.nextPayment = formattedPaymentDate;

    try {
      await _hiveService.updateMember(member.key, member);
      _toastService.successToast('Member updated successfully');
      _getMembers();
    } catch (e) {
      _toastService.errorToast('Failed to updated member');
    }
  }

  // Show a confirmation dialog before updating the member's payment date
  void _showConfirmationDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Payment Confirmation',
            message:
                'Are you sure you want to confirm ${member.name}\'s payment?',
            option1: 'No',
            option2: 'Yes',
          ),
          onConfirm: () => _updateMember(member),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while waiting for the data
      return const Center(child: CircularProgressIndicator());
    } else if (_allMembers.isEmpty) {
      // Show a message if there are no members to display
      return const Center(child: Text('No members to show.'));
    } else {
      DateTime now = DateTime.now();

      // Separate members into two lists based on payment status
      List<Member> duePayments = _allMembers.where((member) {
        DateTime paymentDate = DateTime.parse(member.nextPayment);
        return paymentDate.isBefore(now);
      }).toList();

      List<Member> upToDatePayments = _allMembers.where((member) {
        DateTime paymentDate = DateTime.parse(member.nextPayment);
        return !paymentDate.isBefore(now);
      }).toList();

      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display due payments section
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: const Text(
                  'Due Payments',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: duePayments.length,
                  itemBuilder: (context, index) {
                    Member member = duePayments[index];
                    return _buildMemberItem(context, member);
                  },
                ),
              ),
              // Display up-to-date payments section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: const Text(
                  'Up-to-Date Payments',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: upToDatePayments.length,
                  itemBuilder: (context, index) {
                    Member member = upToDatePayments[index];
                    return _buildMemberItem(context, member);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Widget to build each member item
  Widget _buildMemberItem(BuildContext context, Member member) {
    DateTime paymentDate = DateTime.parse(member.nextPayment);
    bool isDue = paymentDate.isBefore(DateTime.now());
    Color borderColor = isDue
        ? const Color.fromARGB(
            255, 255, 120, 110) // Red border for due payments
        : const Color.fromARGB(
            255, 100, 255, 115); // Green border for up-to-date payments

    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 225, 225),
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${member.name}'),
                  Text('Age: ${member.age}'),
                  Text('Start Date: ${member.startDate}'),
                  Text('Payment Date: ${member.nextPayment}'),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                color: Colors.black,
              ),
              child: IconButton(
                icon: const Icon(Icons.done),
                color: Colors.white,
                onPressed: () {
                  _showConfirmationDialog(context, member);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
