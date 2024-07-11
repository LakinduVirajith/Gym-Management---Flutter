import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:gym_management/widgets/normal_input.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _searchController = TextEditingController();
  final HiveService _hiveService = HiveService();
  final ToastService _toastService = ToastService();
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    // Fetch members when the widget is first created
    _getMembers();
    // Add a listener to the search controller
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch members from the Hive database
  Future<void> _getMembers() async {
    List<Member> members = _hiveService.getMembers();
    setState(() {
      _allMembers = members;
      _filteredMembers = members;
    });
  }

  // Handle search text change to filter the member list
  void _onSearchTextChanged() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      if (searchText.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers
            .where((member) => member.name.toLowerCase().contains(searchText))
            .toList();
      }
    });
  }

  // Delete a member from the Hive database and refresh the member list
  void _deleteMember(int index) async {
    try {
      await _hiveService.deleteMember(index);
      _toastService.successToast('Member deleted successfully');
      _getMembers();
    } catch (e) {
      _toastService.errorToast('Failed to delete member');
    }
  }

  // Show a confirmation dialog before deleting a member
  void _showDeleteConfirmationDialog(
      BuildContext context, String name, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Delete Member',
            message: 'Are you sure you want to delete $name\'s profile?',
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
        child: Column(
          children: [
            if (_allMembers.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.black,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: NormalInput(
                    placeholderText: 'Search',
                    icon: Icons.search,
                    normalController: _searchController,
                  ),
                ),
              ),
            Expanded(
              child: _filteredMembers.isEmpty
                  ? const Center(child: Text('No members to show.'))
                  : ListView.builder(
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        // Reverse the index to display the most recently added members first
                        int reversedIndex = _filteredMembers.length - 1 - index;
                        Member member = _filteredMembers[reversedIndex];
                        return Container(
                          margin: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 225, 225, 225),
                            border:
                                Border.all(color: Colors.black54, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ${member.name}'),
                                      Text('Age: ${member.age}'),
                                      Text('Start Date: ${member.startDate}'),
                                      Text(
                                          'Next Payment: ${member.nextPayment}'),
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
                                          context, member.name, reversedIndex);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
