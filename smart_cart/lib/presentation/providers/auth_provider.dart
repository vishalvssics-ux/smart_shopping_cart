import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider()
      : _authRepository =
            AuthRepositoryImpl(AuthRemoteDataSource());

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  String? _successMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _status == AuthStatus.loading;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? profileImage,
  }) async {
    _setLoading();
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        profileImage: profileImage,
      );
      _user = user;
      _status = AuthStatus.authenticated;
      if (user.id != null) await _saveUserId(user.id!);
      if (user.token != null) await _saveToken(user.token!);
      _setSuccess('Registration successful!');
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
      return false;
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _setLoading();
    try {
      final user = await _authRepository.login(
          identifier: identifier, password: password);
      _user = user;
      _status = AuthStatus.authenticated;
      if (user.id != null) await _saveUserId(user.id!);
      if (user.token != null) await _saveToken(user.token!);
      _setSuccess('Welcome back, ${user.name}!');
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
      return false;
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<bool> forgotPassword({required String email}) async {
    _setLoading();
    try {
      final message =
          await _authRepository.forgotPassword(email: email);
      _status = AuthStatus.unauthenticated;
      _setSuccess(message);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
      return false;
    }
  }

  // ─── Reset Password ───────────────────────────────────────────────────────
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading();
    try {
      final message = await _authRepository.resetPassword(
          email: email, otp: otp, newPassword: newPassword);
      _status = AuthStatus.unauthenticated;
      _setSuccess(message);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
      return false;
    }
  }

  // ─── Get Profile ──────────────────────────────────────────────────────────
  Future<void> getUserProfile() async {
    final userId = await _getSavedUserId();
    if (userId == null) return;
    _setLoading();
    try {
      final user = await _authRepository.getUserProfile(userId);
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
    }
  }

  // ─── Update Profile ───────────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? profileImage,
  }) async {
    final userId = _user?.id ?? await _getSavedUserId();
    if (userId == null) {
      _setError('User not found');
      return false;
    }
    _setLoading();
    try {
      final user = await _authRepository.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        email: email,
        profileImage: profileImage,
      );
      _user = user;
      _status = AuthStatus.authenticated;
      _setSuccess('Profile updated successfully!');
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('HttpException: ', ''));
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Auto Login ───────────────────────────────────────────────────────────
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    if (userId == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
    try {
      final user = await _authRepository.getUserProfile(userId);
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, userId);
  }

  Future<String?> _getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
  }
}
