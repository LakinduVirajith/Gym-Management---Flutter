class Member {
  final String fireID;
  final String fullName;
  final int age;
  final String height;
  final String weight;
  final String goal;
  final String notes;
  final String startDate;
  final String nextPayment;

  Member({
    required this.fireID,
    required this.fullName,
    this.age = 0,
    this.height = '',
    this.weight = '',
    this.goal = '',
    this.notes = '',
    required this.startDate,
    required this.nextPayment,
  });
}
