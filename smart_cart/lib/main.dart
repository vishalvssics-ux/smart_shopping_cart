import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_cart/core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/register/register_screen.dart';
import 'presentation/screens/forgot_password/forgot_password_screen.dart';
import 'presentation/screens/reset_password/reset_password_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/edit_profile/edit_profile_screen.dart';
import 'presentation/screens/bottom_nav/bottom_nav_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const SmartCartApp(),
    ),
  );
}

class SmartCartApp extends StatelessWidget {
  const SmartCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppConstants.splash,
      routes: {
        AppConstants.splash: (_) => const SplashScreen(),
        AppConstants.onboarding: (_) => const OnboardingScreen(),
        AppConstants.login: (_) => const LoginScreen(),
        AppConstants.register: (_) => const RegisterScreen(),
        AppConstants.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppConstants.resetPassword: (_) => const ResetPasswordScreen(),
        AppConstants.profile: (_) => const ProfileScreen(),
        AppConstants.editProfile: (_) => const EditProfileScreen(),
        AppConstants.bottomnav: (_) => const BottomNavScreen(),
      },
    );
  }
}
