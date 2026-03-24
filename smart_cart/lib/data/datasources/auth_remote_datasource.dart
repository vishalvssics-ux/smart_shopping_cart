import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? profileImage,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
      if (profileImage != null) 'profileImage': profileImage,
    };

    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    return _handleResponse(response);
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse(ApiConstants.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return _handleResponse(response);
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'otp': otp, 'newPassword': newPassword}),
    );

    return _handleResponse(response);
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.getUserProfile(userId)),
      headers: {'Content-Type': 'application/json'},
    );

    return _handleResponse(response);
  }

  // Update Profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    required String email,
    String? profileImage,
  }) async {
    final body = {
      'name': name,
      'phone': phone,
      'email': email,
      if (profileImage != null) 'profileImage': profileImage,
    };

    final response = await http.put(
      Uri.parse(ApiConstants.updateUserProfile(userId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic>
          ? decoded
          : {'data': decoded};
    } else {
      final message = decoded is Map
          ? (decoded['message'] ?? decoded['error'] ?? 'Request failed')
          : 'Request failed';
      throw HttpException(message.toString());
    }
  }
}
