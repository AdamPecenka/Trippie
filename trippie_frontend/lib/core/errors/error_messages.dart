abstract final class ErrorMessages {
  static String fromCode(String code) {
    switch (code) {
      case 'Invalid_Credentials':
        return 'Incorrect email or password.';
      case 'User_Not_Found':
        return 'No account found with this email.';
      case 'Email_Already_Exists':
        return 'An account with this email already exists.';
      case 'Phone_Already_Exists':
        return 'An account with this phone number already exists.';
      case 'Invalid_Refresh_Token':
        return 'Your session has expired. Please log in again.';
      case 'Trip_Not_Found':
        return 'This trip no longer exists.';
      case 'Forbidden':
        return 'You don\'t have permission to do that.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}