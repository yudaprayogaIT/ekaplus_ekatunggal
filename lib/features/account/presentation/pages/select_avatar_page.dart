// lib/features/account/presentation/pages/select_avatar_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectAvatarPage extends StatefulWidget {
  final User user;

  const SelectAvatarPage({Key? key, required this.user}) : super(key: key);

  @override
  State<SelectAvatarPage> createState() => _SelectAvatarPageState();
}

class _SelectAvatarPageState extends State<SelectAvatarPage> {
  final List<String> avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
    'assets/images/avatars/avatar_7.png',
    'assets/images/avatars/avatar_8.png',
    'assets/images/avatars/avatar_9.png',
    'assets/images/avatars/avatar_10.png',
    'assets/images/avatars/avatar_11.png',
    'assets/images/avatars/avatar_12.png',
    'assets/images/avatars/avatar_13.png',
    'assets/images/avatars/avatar_14.png',
    'assets/images/avatars/avatar_15.png',
    'assets/images/avatars/avatar_16.png',
    'assets/images/avatars/avatar_17.png',
    'assets/images/avatars/avatar_18.png',
    'assets/images/avatars/avatar_19.png',
    'assets/images/avatars/avatar_20.png',
    'assets/images/avatars/avatar_21.png',
    'assets/images/avatars/avatar_22.png',
    'assets/images/avatars/avatar_23.png',
    'assets/images/avatars/avatar_24.png',
  ];

  final List<Color> bgColors = [
    const Color(0xFF000000),
    const Color(0xFFFF69B4),
    const Color(0xFF00CED1),
    const Color(0xFF808080),
    const Color(0xFF4169E1),
    const Color(0xFF90EE90),
    const Color(0xFFFFB6C1),
  ];

  String? selectedAvatar;
  Color selectedBgColor = const Color(0xFF000000);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.profilePic != null &&
        widget.user.profilePic!.startsWith('assets/')) {
      selectedAvatar = widget.user.profilePic;
    } else {
      selectedAvatar = avatars[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfilePictureUpdateSuccess) {
          // Update global auth session
          context.read<AuthSessionCubit>().updateUser(state.user);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Avatar berhasil diubah',
                style: TextStyle(fontFamily: AppFonts.primaryFont),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Go back
          context.pop();
        } else if (state is ProfilePictureUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontFamily: AppFonts.primaryFont),
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => isLoading = false);
        } else if (state is AuthLoading) {
          setState(() => isLoading = true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: CustomAppBar(
          title: 'Pilih Avatar',
          onLeadingPressed: () => context.pop(),
        ),
        body: Column(
          children: [
            // Preview Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.primaryColor,
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: selectedBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: selectedAvatar != null
                          ? Image.asset(
                              selectedAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Avatar',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = avatars[index];
                        final isSelected = selectedAvatar == avatar;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAvatar = avatar;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedBgColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Atur Warna Background',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: bgColors.map((color) {
                        final isSelected = selectedBgColor == color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBgColor = color;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveAvatar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secondaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAvatar() {
    if (selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih avatar terlebih dahulu',
            style: TextStyle(fontFamily: AppFonts.primaryFont),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Trigger update via AuthBloc
    context.read<AuthBloc>().add(
          UpdateProfilePictureEvent(
            userId: widget.user.phone, // Using phone as userId
            profilePicPath: selectedAvatar,
          ),
        );
  }
}