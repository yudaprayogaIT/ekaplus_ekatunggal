// lib/features/account/presentation/widgets/account_logged_in_view.dart
import 'dart:io';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/profile_picture_options.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AccountLoggedInView extends StatelessWidget {
  final User user;

  const AccountLoggedInView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to always get the latest user data
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, sessionState) {
        // Get current user from session (might have updated phone/email)
        final currentUser = sessionState is AuthSessionAuthenticated
            ? sessionState.user
            : user;

        return Container(
          width: double.infinity,
          color: AppColors.whiteColor,
          child: Column(
            children: [
              // Content with padding
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Avatar & Name
                    _buildProfileHeader(context, currentUser),

                    const SizedBox(height: 24),

                    // Nama Lengkap
                    _buildInfoSection(
                      label: 'Nama Lengkap',
                      value: currentUser.fullName,
                      context: context,
                      userId: currentUser.phone, // Always use current phone
                    ),

                    const Divider(height: 1),

                    const SizedBox(height: 12),

                    // Nomor Handphone
                    _buildInfoSection(
                      label: 'Nomor Handphone',
                      value: currentUser.phone,
                      context: context,
                      userId: currentUser.phone,
                    ),

                    const Divider(height: 1),

                    const SizedBox(height: 12),

                    // Email
                    _buildInfoSection(
                      label: 'Email',
                      value: currentUser.email,
                      context: context,
                      userId: currentUser.phone,
                    ),

                    const Divider(height: 1),

                    const SizedBox(height: 20),

                    // Company Card
                    _buildCompanyCard(),

                    const SizedBox(height: 20),

                    // Connect Company Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to connect company page
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.secondaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Hubungkan Perusahaan',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Full width divider
              Container(
                width: double.infinity,
                height: 5,
                color: const Color(0xFFE0E0E0),
              ),

              // Settings Section
              _buildSettingsSection(context, currentUser),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User currentUser) {
    return Column(
      children: [
        // Avatar with camera icon
        Stack(
          children: [
            // Profile Picture
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipOval(
                child: _buildProfileImage(currentUser),
              ),
            ),

            // Camera Icon Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showProfilePictureOptions(context, currentUser),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Name
        Text(
          currentUser.fullName,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),

        const SizedBox(height: 4),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x65A7A7A7), width: 1),
            color: const Color(0x33A7A7A7),
          ),
          child: Text(
            'Belum terhubung dengan perusahaan',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 12,
              color: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(User currentUser) {
    // Check if user has profile_pic (avatar or uploaded image)
    if (currentUser.profilePic != null && currentUser.profilePic!.isNotEmpty) {
      // Check if it's a URL (uploaded image) or asset path (avatar)
      if (currentUser.profilePic!.startsWith('http')) {
        return Image.network(
          currentUser.profilePic!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
        );
      } else if (currentUser.profilePic!.startsWith('assets/')) {
        return Image.asset(
          currentUser.profilePic!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(currentUser),
        );
      }
    }

    // Default avatar
    return _buildDefaultAvatar(currentUser);
  }

  Widget _buildDefaultAvatar(User currentUser) {
    return Image.asset(
      'assets/images/avatar_placeholder.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.primaryColor,
        child: Center(
          child: Text(
            _getInitials(currentUser.fullName),
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfilePictureOptions(BuildContext context, User currentUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => ProfilePictureOptionsSheet(
        user: currentUser,
        onDismiss: () => Navigator.pop(sheetContext),
      ),
    );
  }

  Widget _buildInfoSection({
    required String label,
    required String value,
    required BuildContext context,
    required String userId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 12,
            color: AppColors.grayColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate based on label
                if (label == 'Nama Lengkap') {
                  // Direct navigate (no password needed)
                  context.pushNamed(
                    'edit-name',
                    extra: {
                      'userId': userId,
                      'currentName': value,
                    },
                  );
                } else if (label == 'Nomor Handphone') {
                  // Navigate via password verification
                  context.pushNamed(
                    'verify-password',
                    extra: {
                      'userId': userId,
                      'title': 'Ubah Nomor Handphone',
                      'subtitle': 'Masukkan password untuk verifikasi',
                      'nextRoute': 'edit-contact',
                      'nextRouteExtra': {
                        'currentPhone': value,
                        'type': 'phone',
                      },
                    },
                  );
                } else if (label == 'Email') {
                  // Navigate via password verification
                  context.pushNamed(
                    'verify-password',
                    extra: {
                      'userId': userId,
                      'title': 'Ubah Email',
                      'subtitle': 'Masukkan password untuk verifikasi',
                      'nextRoute': 'edit-contact',
                      'nextRouteExtra': {
                        'currentEmail': value,
                        'type': 'email',
                      },
                    },
                  );
                }
              },
              child: Text(
                'Ubah',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 208,
              height: 165,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/account/linkCompany.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[100],
                    child: const Icon(
                      Icons.business,
                      size: 56,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            right: 0,
            child: SizedBox(
              width: 240,
              child: Text(
                'Akses data transaksi dan fitur menarik lainnya',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, User currentUser) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pengaturan dan Keamanan',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Ganti Password',
            onTap: () {
              // Navigate to change password with current phone
              context.pushNamed(
                'change-password',
                extra: {
                  'userId': currentUser.phone, // Always use current phone
                },
              );
            },
          ),

          const Divider(height: 1),

          _buildSettingItem(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 24, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(fontFamily: AppFonts.primaryFont),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthSessionCubit>().logout();
              context.goNamed('home');
            },
            child: Text(
              'Logout',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}