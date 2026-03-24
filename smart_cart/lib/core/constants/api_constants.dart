class ApiConstants {
  static const String baseUrl = 'https://smart-cart-delta-rose.vercel.app';

  // Auth
  static const String register = '$baseUrl/api/users/register';
  static const String login = '$baseUrl/api/users/login';
  static const String forgotPassword = '$baseUrl/api/users/forgot-password';
  static const String resetPassword = '$baseUrl/api/users/reset-password';

  // User
  static String getUserProfile(String userId) =>
      '$baseUrl/api/users/$userId';
  static String updateUserProfile(String userId) =>
      '$baseUrl/api/users/update/$userId';
}
