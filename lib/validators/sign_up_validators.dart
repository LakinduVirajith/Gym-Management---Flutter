class SignUpValidators {
  static String? validateMobileNumber(String value) {
    if (value.isEmpty) return '📞 Mobile number is required';
    if (!RegExp(r'^\+?\d{6,15}$').hasMatch(value)) {
      return '📞 Enter a valid mobile number';
    }

    return null;
  }

  static String? validateFitnessCenterName(String value) {
    if (value.isEmpty) return '🏋️ Fitness Center name is required';
    if (value.length < 2) {
      return '🏋️ Fitness Center name must be at least 2 characters';
    }
    return null;
  }

  static String? validateFitnessCenterAddress(String value) {
    if (value.isEmpty) return '🏢 Fitness Center address is required';
    if (value.length < 2) {
      return '🏢 Fitness Center address must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) return '📧 Email address is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return '📧 Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return '🔐 Password is required';
    if (value.length < 6) return '🔐 Password must be at least 6 characters';
    return null;
  }
}
