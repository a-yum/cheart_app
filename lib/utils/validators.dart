class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  static String? email(String? value) {
    if (value != null && value.isNotEmpty && !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }
}