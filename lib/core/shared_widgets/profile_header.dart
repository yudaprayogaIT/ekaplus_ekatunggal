// lib/core/shared_widgets/profile_header.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onCompanyTap;

  const ProfileHeader({
    super.key,
    this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        // Build avatar based on auth state
        Widget buildAvatar() {
          if (authState is AuthSessionAuthenticated) {
            final user = authState.user;
            
            // Check if user has profile picture
            if (user.profilePic != null && user.profilePic!.isNotEmpty) {
              // Check if it's a URL (uploaded image) or asset path (avatar)
              if (user.profilePic!.startsWith('http')) {
                return Image.network(
                  user.profilePic!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.fullName),
                );
              } else if (user.profilePic!.startsWith('assets/')) {
                return Image.asset(
                  user.profilePic!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.fullName),
                );
              } else {
                // Local file path (from gallery)
                return Image.asset(
                  user.profilePic!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.fullName),
                );
              }
            }
            
            // No profile pic - show default with initials
            return _buildDefaultAvatar(user.fullName);
          }
          
          // Guest - show placeholder
          return Image.asset(
            'assets/images/avatar_placeholder.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primaryColor,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        }

        // Determine what to show based on auth state
        Widget buildTextArea() {
          if (authState is AuthSessionGuest) {
            // GUEST STATE
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo, Selamat Datang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primaryFont,
                    color: AppColors.blackColor,
                    fontSize: 15,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Masuk atau Daftar Sekarang',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            );
          } else if (authState is AuthSessionAuthenticated) {
            final user = authState.user;
            final status = authState.status;

            if (status == UserStatus.member) {
              // MEMBER STATE (with company)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user.firstName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.blackColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onCompanyTap ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih perusahaan (segera hadir)'),
                            ),
                          );
                        },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PT Nama Perusahaan',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // LOGGED IN STATE (regular user)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user.firstName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.blackColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            }
          }

          // Loading or initial state
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Memuat...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primaryFont,
                  color: AppColors.blackColor,
                  fontSize: 15,
                ),
              ),
            ],
          );
        }

        // Handle tap action
        void handleTap() {
          if (authState is AuthSessionGuest) {
            context.pushNamed('login');
          } else if (authState is AuthSessionAuthenticated) {
            context.pushNamed('account');
          }
        }

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: handleTap,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(child: buildAvatar()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: buildTextArea()),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifikasi (segera hadir)')),
                );
              },
              icon: const Icon(
                CupertinoIcons.bell_solid,
                color: AppColors.grayColor,
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper: Build default avatar with initials
  Widget _buildDefaultAvatar(String fullName) {
    return Container(
      color: AppColors.primaryColor,
      child: Center(
        child: Text(
          _getInitials(fullName),
          style: const TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper: Get initials from full name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
