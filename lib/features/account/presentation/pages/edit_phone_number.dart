// lib/features/account/presentation/pages/edit_phone_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditPhonePage extends StatefulWidget {
  final String userId;
  final String currentPhone;

  const EditPhonePage({
    Key? key,
    required this.userId,
    required this.currentPhone,
  }) : super(key: key);

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Ubah Nomor Handphone',
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
            
            // Navigate to OTP verification page
            context.pushNamed(
              'verify-phone',
              extra: {
                'userId': widget.userId,
                'phone': state.pendingPhone,
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
                // Current Phone Info
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
                        'Nomor saat ini:',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.grayColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.currentPhone,
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

                // New Phone Number
                Text(
                  'Nomor Handphone Baru',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 081234567890',
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
                      return 'Nomor handphone tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9+]+$').hasMatch(value)) {
                      return 'Nomor handphone tidak valid';
                    }
                    
                    // Normalize for comparison
                    String normalizedNew = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (normalizedNew.startsWith('0')) {
                      normalizedNew = '62${normalizedNew.substring(1)}';
                    }
                    
                    String normalizedCurrent = widget.currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
                    if (normalizedCurrent.startsWith('0')) {
                      normalizedCurrent = '62${normalizedCurrent.substring(1)}';
                    }
                    
                    if (normalizedNew == normalizedCurrent) {
                      return 'Nomor baru sama dengan nomor lama';
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
      // Normalize phone number
      String newPhone = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (newPhone.startsWith('0')) {
        newPhone = '62${newPhone.substring(1)}';
      }
      
      context.read<ProfileUpdateCubit>().requestPhoneUpdate(
            userId: widget.userId,
            newPhone: newPhone,
            password: _passwordController.text,
          );
    }
  }
}
