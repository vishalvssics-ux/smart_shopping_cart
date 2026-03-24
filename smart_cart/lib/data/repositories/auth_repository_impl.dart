import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? profileImage,
  }) async {
    final data = await _remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      profileImage: profileImage,
    );
    return UserModel.fromJson(data['user'] ?? data);
  }

  @override
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    final data = await _remoteDataSource.login(
      identifier: identifier,
      password: password,
    );
    final user = UserModel.fromJson(data['user'] ?? data);
    return user.copyWith(token: data['token']);
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final data = await _remoteDataSource.forgotPassword(email: email);
    return data['message']?.toString() ?? 'OTP sent to your email';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final data = await _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    return data['message']?.toString() ?? 'Password reset successfully';
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final data = await _remoteDataSource.getUserProfile(userId);
    return UserModel.fromJson(data['user'] ?? data);
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    required String email,
    String? profileImage,
  }) async {
    final data = await _remoteDataSource.updateUserProfile(
      userId: userId,
      name: name,
      phone: phone,
      email: email,
      profileImage: profileImage,
    );
    return UserModel.fromJson(data['user'] ?? data);
  }
}
