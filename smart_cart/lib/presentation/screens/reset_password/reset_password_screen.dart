import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: _email ?? '',
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset successfully!'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pushNamedAndRemoveUntil(
          context, AppConstants.login, (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Reset failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.security_rounded,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            Text('Enter OTP & New Password',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),

            if (_email != null)
              Text(
                'OTP sent to $_email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            const SizedBox(height: 36),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Manual email field if not passed
                  if (_email == null || _email!.isEmpty) ...[
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'your@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => _email = v,
                      validator: (v) =>
                          (v == null || !v.contains('@'))
                              ? 'Invalid email'
                              : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // OTP Input
                  CustomTextField(
                    label: 'OTP Code',
                    hint: 'Enter 6-digit OTP',
                    controller: _otpController,
                    prefixIcon: Icons.pin_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.length < 4)
                            ? 'Enter valid OTP'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'New Password',
                    hint: 'Min 8 characters',
                    controller: _newPasswordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 8)
                            ? 'Min 8 characters'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Confirm New Password',
                    hint: 'Repeat password',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Reset Password',
                    onPressed: _resetPassword,
                    isLoading: auth.isLoading,
                    icon: Icons.check_circle_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
