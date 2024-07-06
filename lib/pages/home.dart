import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
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
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    // Fetch members when the widget is first created
    _membersFuture = _getMembers();
  }

  // Fetch members from the Hive database and sort them by payment date
  Future<List<Member>> _getMembers() async {
    List<Member> members = await _hiveService.getMembers();

    members.sort((a, b) {
      DateTime aPaymentDate = DateTime.parse(a.nextPayment);
      DateTime bPaymentDate = DateTime.parse(b.nextPayment);
      return aPaymentDate.compareTo(bPaymentDate);
    });

    return members;
  }

  // Add one month to the given date while handling edge cases
  DateTime _addOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }

    // Handle February and end-of-month cases
    int day = date.day;
    int lastDayOfNextMonth =
        DateTime(year, month + 1, 0).day; // Last day of next month
    if (day > lastDayOfNextMonth) {
      day = lastDayOfNextMonth;
    }

    return DateTime(year, month, day);
  }

  // Update the member's payment date and notify the user
  void _updateMember(Member member) async {
    DateTime paymentDate = _addOneMonth(DateTime.parse(member.nextPayment));
    String formattedPaymentDate = DateFormat('yyyy-MM-dd').format(paymentDate);
    member.nextPayment = formattedPaymentDate;

    try {
      await _hiveService.updateMember(member.key, member);
      setState(() {
        _membersFuture = _getMembers();
      });
      _toastService.successToast('member updated successfully');
    } catch (e) {
      _toastService.errorToast('failed to updated member');
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
            message: 'Are you sure you want to confirm this member\'s payment?',
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
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Member>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for the data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Show an error message if there was an error fetching the data
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show a message if there are no members to display
              return const Center(child: Text('No members to show.'));
            } else {
              List<Member> members = snapshot.data!;
              DateTime now = DateTime.now();

              // Separate members into two lists based on payment status
              List<Member> duePayments = members.where((member) {
                DateTime paymentDate = DateTime.parse(member.nextPayment);
                return paymentDate.isBefore(now);
              }).toList();

              List<Member> upToDatePayments = members.where((member) {
                DateTime paymentDate = DateTime.parse(member.nextPayment);
                return !paymentDate.isBefore(now);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
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
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
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
              );
            }
          },
        ),
      ),
    );
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
      margin: const EdgeInsets.all(8.0),
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
