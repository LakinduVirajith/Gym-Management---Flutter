import 'package:flutter/material.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';

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
    _membersFuture = _getMembers();
  }

  Future<List<Member>> _getMembers() async {
    return _hiveService.getMembers();
  }

  void _deleteMember(int index) async {
    await _hiveService.deleteMember(index);
    setState(() {
      _membersFuture = _getMembers();
    });
    _toastService.successToast('member deleted successfully');
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Member"),
          content: const Text("Are you sure you want to delete this member?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMember(index);
              },
            ),
          ],
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
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No members to show.'));
            } else {
              List<Member> members = snapshot.data!;
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  int reversedIndex = members.length - 1 - index;
                  Member member = members[reversedIndex];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: const Color.fromARGB(255, 225, 225, 225),
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
                                Text('Payment Date: ${member.paymentDate}'),
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
