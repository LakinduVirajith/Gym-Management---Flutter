class InputValidator {
  // static String? validateMobileNumber(String value) {
  //   if (value.isEmpty) return '📱 Mobile number is required';
  //   if (!RegExp(r'^\d{10}$').hasMatch(value)) {
  //     return '📞 Mobile number must be 10 digits';
  //   }
  //   return null;
  // }

  static String? validateGymName(String value) {
    if (value.isEmpty) return '🏋️ Gym name is required';
    if (value.length < 2) return '🏋️ Gym name must be at least 2 characters';
    return null;
  }

  static String? validateGymAddress(String value) {
    if (value.isEmpty) return '📍 Gym address is required';
    if (value.length < 2) return '📍 Gym address must be at least 2 characters';
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) return '✉️ Email address is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return '📧 Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return '🔐 Password is required';
    if (value.length < 6) return '🔒 Password must be at least 6 characters';
    return null;
  }
}
