class Member {
  final String id; // FIRESTORE DOCUMENT ID
  final String name;
  final int age;
  final String height;
  final String weight;
  final String goal;
  final String remarks;
  final String startDate;
  final String nextPayment;

  Member({
    required this.id,
    required this.name,
    this.age = 0,
    this.height = '',
    this.weight = '',
    this.goal = '',
    this.remarks = '',
    required this.startDate,
    required this.nextPayment,
  });
}
