import 'package:flutter/material.dart';
import 'package:gym_management/models/member.dart';
import 'package:gym_management/services/hive_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final HiveService _hiveService = HiveService();

  @override
  void initState() {
    super.initState();
    _printMembers();
  }

  Future<void> _printMembers() async {
    List<Member> members = _hiveService.getMembers();
    print('All Members:');
    members.forEach((member) {
      print(
          'Name: ${member.name}, Age: ${member.age}, Start Date: ${member.startDate}, Payment Date: ${member.paymentDate}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('List Page'),
      ),
    );
  }
}
