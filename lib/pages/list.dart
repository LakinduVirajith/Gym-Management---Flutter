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
        _toastService
            .warningToast("⚠️ Your session has expired. Please log in again.");

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
          fullName: data['fullName'] ?? '',
          age: calculatedAge,
          height: data['heightInCm']?.toString() ?? '',
          weight: data['weightInKg']?.toString() ?? '',
          goal: data['fitnessGoal']?.toString() ?? '',
          notes: data['notes']?.toString() ?? '',
          startDate: data['membershipStart'] ?? '',
          nextPayment: data['nextPaymentDue'] ?? '',
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
          final idMatch = member.fireID.toLowerCase().contains(searchText);
          final nameMatch = member.fullName.toLowerCase().contains(searchText);
          final goalMatch = member.goal.toLowerCase().contains(searchText);
          final notesMatch = member.notes.toLowerCase().contains(searchText);

          return nameMatch || idMatch || goalMatch || notesMatch;
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
      // REFRESH LIST AFTER DELETION
      await _fetchMembers();
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String name, String memberId) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          confirmationMessage: ConfirmationMessage(
            topic: 'Remove Member',
            message:
                'Are you sure you want to permanently remove "$name" from your member list? This action cannot be undone.',
            option1: 'Cancel',
            option2: 'Delete',
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
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 20.0,
                  left: 12.0,
                  right: 12.0,
                ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMembers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.group_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No Members Found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _allMembers.isEmpty
                                      ? 'Start building your fitness community by adding members.'
                                      : 'No matching members found. Try searching by name, goal, notes, or member ID.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredMembers.length,
                          itemBuilder: (context, index) {
                            // REVERSE THE LIST TO SHOW NEWEST FIRST
                            final reversedIndex =
                                _filteredMembers.length - 1 - index;
                            final member = _filteredMembers[reversedIndex];

                            return Container(
                              margin: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 110, 132, 255),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Member ID:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Text(
                                            'Full Name:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Text(
                                            'Age:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (member.height.isNotEmpty)
                                            const Text(
                                              'Height (cm):',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          if (member.weight.isNotEmpty)
                                            const Text(
                                              'Weight (kg):',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          if (member.height.isNotEmpty)
                                            const Text(
                                              'Fitness Goal:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          if (member.weight.isNotEmpty)
                                            const Text(
                                              'Additional Notes:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          const Text(
                                            'Membership Start:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Text(
                                            'Next Payment Due:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.fireID,
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          Text(
                                            member.fullName,
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          Text(
                                            '${member.age}',
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          if (member.height.isNotEmpty)
                                            Text(
                                              member.height,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          if (member.weight.isNotEmpty)
                                            Text(
                                              member.weight,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          if (member.height.isNotEmpty)
                                            Text(
                                              member.goal,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          if (member.weight.isNotEmpty)
                                            Text(
                                              member.notes,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          Text(member.startDate),
                                          Text(
                                            member.nextPayment,
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        color: Colors.black,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.white,
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(
                                          context,
                                          member.fullName,
                                          member.fireID,
                                        ),
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
