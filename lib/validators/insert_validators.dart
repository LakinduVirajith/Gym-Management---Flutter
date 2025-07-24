class InsertValidators {
  static String? validateName(String value) {
    if (value.isEmpty) return '🧑 Full name is required';
    return null;
  }

  static String? validateDateOfBirth(String value) {
    if (value.isEmpty) return '🎂 Date of birth is required';
    return null;
  }

  static String? validateHeight(String value) {
    if (value.isEmpty) return '📏 Height is required';
    if (double.tryParse(value) == null) return '📏 Height must be a number';
    return null;
  }

  static String? validateWeight(String value) {
    if (value.isEmpty) return '⚖️ Weight is required';
    if (double.tryParse(value) == null) return '⚖️ Weight must be a number';
    return null;
  }

  static String? validateGoal(String value) {
    if (value.isEmpty) return '🎯 Fitness goal is required';
    return null;
  }

  static String? validateMembershipStart(String value) {
    if (value.isEmpty) return '📅 Membership start date is required';
    return null;
  }
}
