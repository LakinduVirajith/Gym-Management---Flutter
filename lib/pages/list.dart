import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    // Fetch members when the widget is first created
    _membersFuture = _getMembers();
  }

  // Fetch members from the Hive database
  Future<List<Member>> _getMembers() async {
    return _hiveService.getMembers();
  }

  // Delete a member from the Hive database and refresh the member list
  void _deleteMember(int index) async {
    try {
      await _hiveService.deleteMember(index);
      setState(() {
        _membersFuture = _getMembers();
      });
      _toastService.successToast('member deleted successfully');
    } catch (e) {
      _toastService.errorToast('failed to delete member');
    }
  }

  // Show a confirmation dialog before deleting a member
  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Delete Member',
            message: 'Are you sure you want to delete this member?',
            option1: 'Cancel',
            option2: 'Delete',
          ),
          onConfirm: () => _deleteMember(index),
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
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  // Reverse the index to display the most recently added members first
                  int reversedIndex = members.length - 1 - index;
                  Member member = members[reversedIndex];
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 225, 225, 225),
                      border: Border.all(color: Colors.black54, width: 2.0),
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
                                Text('Next Payment: ${member.nextPayment}'),
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
                              icon: const Icon(Icons.delete),
                              color: Colors.white,
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, reversedIndex);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
