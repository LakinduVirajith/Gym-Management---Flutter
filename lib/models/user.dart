class User {
  final String userName;
  final String mobileNumber;
  final String gymName;
  final String gymAddress;
  final String appStartDate;
  final String paymentDueDate;
  final String lastActiveDate;

  User({
    required this.userName,
    required this.mobileNumber,
    required this.gymName,
    required this.gymAddress,
    required this.appStartDate,
    required this.paymentDueDate,
    required this.lastActiveDate,
  });

  Map<String, dynamic> toJson() => {
        'user_name': userName,
        'mobile_number': mobileNumber,
        'gym_name': gymName,
        'gym_address': gymAddress,
        'app_start_date': appStartDate,
        'payment_due_date': paymentDueDate,
        'last_active_date': lastActiveDate,
      };
}
