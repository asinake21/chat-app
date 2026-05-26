class Validators {
  Validators._();

  // Checks if the email is empty or has an invalid format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Simple email regex pattern to validate email addresses
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Passwords need to be at least 6 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Usernames must be at least 3 characters long
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  // Make sure post is not empty
  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Post content cannot be empty';
    }
    return null;
  }

  // Make sure comment has text
  static String? validateCommentContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Comment content cannot be empty';
    }
    return null;
  }
}
