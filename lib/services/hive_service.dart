import 'package:hive/hive.dart';
import '../models/member.dart';

class HiveService {
  final Box<Member> _memberBox = Hive.box<Member>('members');

  // Add a new member to the Hive database.
  Future<void> addMember(Member member) async {
    try {
      await _memberBox.add(member);
    } catch (e) {
      throw 'Error adding member: $e';
    }
  }

  // Retrieve all members stored in the Hive database.
  List<Member> getMembers() {
    try {
      return _memberBox.values.toList();
    } catch (e) {
      throw 'Error retrieving members: $e';
    }
  }

  // Delete a member from the Hive database at a specified index.
  Future<void> deleteMember(int index) async {
    try {
      await _memberBox.deleteAt(index);
    } catch (e) {
      throw 'Error deleting member: $e';
    }
  }

  // Update an existing member in the Hive database.
  Future<void> updateMember(dynamic key, Member member) async {
    try {
      await _memberBox.put(key, member);
    } catch (e) {
      throw 'Error updating member: $e';
    }
  }
}
