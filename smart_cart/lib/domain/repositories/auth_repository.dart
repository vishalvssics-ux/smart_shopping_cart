import 'package:smart_cart/data/models/user_model.dart';


abstract class AuthRepository {
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? profileImage,
  });

  Future<UserModel> login({
    required String identifier,
    required String password,
  });

  Future<String> forgotPassword({required String email});

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<UserModel> getUserProfile(String userId);

  Future<UserModel> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    required String email,
    String? profileImage,
  });
}
