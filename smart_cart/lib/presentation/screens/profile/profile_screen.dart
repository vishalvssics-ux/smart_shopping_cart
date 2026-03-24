import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().getUserProfile();
    });
  }

  Widget _buildAvatar(String? profileImage, String name) {
    if (profileImage != null && profileImage.startsWith('data:image')) {
      try {
        final base64Str = profileImage.split(',').last;
        final bytes = base64Decode(base64Str);
        return CircleAvatar(
          radius: 54,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 54,
      backgroundColor: AppColors.cardBg,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
            fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: auth.isLoading && user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(
                          context, AppConstants.editProfile),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.logout_rounded, color: Colors.white),
                      onPressed: () async {
                        final authP = context.read<AuthProvider>();
                        await authP.logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                            context, AppConstants.login);
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: _buildAvatar(
                                user?.profileImage, user?.name ?? ''),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Gold member badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFFFD700).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gold Member',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                Text('Exclusive benefits & rewards',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text('Personal Data',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 14),

                      _buildInfoTile(
                          Icons.person_outline_rounded,
                          'Full Name',
                          user?.name ?? '—'),
                      _buildInfoTile(
                          Icons.email_outlined,
                          'Email',
                          user?.email ?? '—'),
                      _buildInfoTile(
                          Icons.phone_outlined,
                          'Phone',
                          user?.phone ?? '—'),
                      _buildInfoTile(
                          Icons.badge_outlined,
                          'User ID',
                          user?.id ?? '—'),

                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Edit Profile',
                        onPressed: () => Navigator.pushNamed(
                            context, AppConstants.editProfile),
                        icon: Icons.edit_rounded,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Logout',
                        isOutlined: true,
                        icon: Icons.logout_rounded,
                        onPressed: () async {
                          final authP = context.read<AuthProvider>();
                          await authP.logout();
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, AppConstants.login);
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
