import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/models/confirmation_message.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/auth_service.dart';
import 'package:gym_management/services/toast_service.dart';
import 'package:gym_management/utils/date_utils.dart';
import 'package:gym_management/widgets/confirmation_dialog.dart';
import 'package:gym_management/widgets/normal_input.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService();
  final _toastService = ToastService();

  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  Set<String> _expandedMembers = {}; // 🔥 Track expanded cards
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _toastService.warningToast("⚠️ Your session has expired. Please log in again.");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('members')
          .get();

      final members = snapshot.docs.map((doc) {
        final data = doc.data();
        final birthdayStr = data['dateOfBirth'];
        int calculatedAge = 0;

        if (birthdayStr != null) {
          final birthday = DateTime.tryParse(birthdayStr.toString());
          if (birthday != null) {
            calculatedAge = AppDateUtils.calculateAge(birthday);
          }
        }

        return Member(
          fireID: doc.id,
          fullName: data['fullName'],
          age: calculatedAge,
          height: data['heightInCm'].toString(),
          weight: data['weightInKg'].toString(),
          goal: data['fitnessGoal'].toString(),
          notes: data['notes']?.toString() ?? '',
          startDate: data['membershipStart'],
          nextPayment: data['nextPaymentDue'],
          subscriptionPlan: data['subscriptionPlan'],
          mobileNumber: data['mobileNumber'],
        );
      }).toList();

      setState(() {
        _allMembers = members;
        _filteredMembers = members;
      });
    } catch (e) {
      _toastService.errorToast("❌ Failed to load members. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchTextChanged() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      if (searchText.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers.where((member) {
          return member.fireID.toLowerCase().contains(searchText) ||
              member.fullName.toLowerCase().contains(searchText) ||
              member.mobileNumber.toLowerCase().contains(searchText) ||
              member.goal.toLowerCase().contains(searchText) ||
              member.notes.toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _deleteMember(String memberId) async {
    final currentUser = _authService.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('members')
          .doc(memberId)
          .delete();

      _toastService.successToast('✅ Member deleted successfully.');
    } catch (e) {
      _toastService.errorToast('❌ Failed to delete member. Please try again.');
    } finally {
      await _fetchMembers();
    }
  }

  void _showRemoveConfirmationDialog(BuildContext context, String name, String memberId) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: '🗑️ Remove Member',
            message: 'Are you sure you want to permanently remove $name ($memberId)? This action cannot be undone.',
            option1: 'No, Keep',
            option2: 'Yes, Remove',
          ),
          onConfirm: () async {
            await _deleteMember(memberId);
            if (mounted) Navigator.pop(context);
          },
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: NormalInput(
                    placeholderText: 'Search',
                    icon: Icons.search,
                    normalController: _searchController,
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMembers.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No Members Found',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Start adding members or try searching by ID, name, mobile, goal, or notes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredMembers.length,
                          itemBuilder: (context, index) {
                            final reversedIndex = _filteredMembers.length - 1 - index;
                            final member = _filteredMembers[reversedIndex];
                            final isExpanded = _expandedMembers.contains(member.fireID);

                            return Container(
                              margin: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color.fromARGB(255, 110, 132, 255), width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // BASIC INFO
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                         '${member.fullName} (${member.fireID})',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                          onPressed: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedMembers.remove(member.fireID);
                                              } else {
                                                _expandedMembers.add(member.fireID);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Mobile: ${member.mobileNumber}'),
                                    Text('Goal: ${member.goal}'),
                                    if (member.notes.isNotEmpty) Text('Notes: ${member.notes}'),
                                    // EXPANDED DETAILS
                                    if (isExpanded) ...[
                                      const SizedBox(height: 12),
                                     
                                      Text('Age: ${member.age}'),
                                      if (member.height.isNotEmpty) Text('Height: ${member.height} cm'),
                                      if (member.weight.isNotEmpty) Text('Weight: ${member.weight} kg'),
                                      Text('Membership Start: ${member.startDate}'),
                                      Text('Next Payment Due: ${member.nextPayment}'),
                                      Text('Subscription Plan: ${member.subscriptionPlan}'),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        onPressed: () => _showRemoveConfirmationDialog(
                                            context, member.fullName, member.fireID),
                                        icon: const Icon(Icons.delete),
                                        label: const Text("Remove Member"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
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
