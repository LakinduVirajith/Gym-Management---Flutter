import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String startDate;

  @HiveField(3)
  String nextPayment;

  Member(
      {required this.name,
      required this.age,
      required this.startDate,
      required this.nextPayment});
}
