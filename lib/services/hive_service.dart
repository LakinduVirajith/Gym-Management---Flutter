import 'package:hive/hive.dart';
import '../models/member.dart';

class HiveService {
  final Box<Member> _memberBox = Hive.box<Member>('members');

  Future<void> addMember(Member member) async {
    await _memberBox.add(member);
  }

  List<Member> getMembers() {
    return _memberBox.values.toList();
  }

  Future<void> deleteMember(int index) async {
    await _memberBox.deleteAt(index);
  }
}
