// lib/features/account/presentation/pages/edit_email_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditEmailPage extends StatefulWidget {
  final String userId;
  final String currentEmail;

  const EditEmailPage({
    Key? key,
    required this.userId,
    required this.currentEmail,
  }) : super(key: key);

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Ubah Email',
        onLeadingPressed: () => context.pop(),
      ),
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateAwaitingVerification) {
            // Show OTP message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
            
            context.pushNamed(
              'verify-email',
              extra: {
                'userId': widget.userId,
                'email': state.pendingEmail,
              },
            );
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Email Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email saat ini:',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.grayColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.currentEmail,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // New Email
                Text(
                  'Email Baru',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Contoh: user@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    if (value.toLowerCase() == widget.currentEmail.toLowerCase()) {
                      return 'Email baru sama dengan email lama';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Confirmation
                Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password Anda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan password untuk verifikasi perubahan',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 12,
                    color: AppColors.grayColor,
                  ),
                ),
                const SizedBox(height: 24),

                BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;
                    
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Lanjutkan',
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileUpdateCubit>().requestEmailUpdate(
            userId: widget.userId,
            newEmail: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
          );
    }
  }
}