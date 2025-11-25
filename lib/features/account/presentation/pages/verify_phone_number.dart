
// lib/features/account/presentation/pages/verify_phone_change_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyPhoneChangePage extends StatefulWidget {
  final String userId;
  final String phone;

  const VerifyPhoneChangePage({
    Key? key,
    required this.userId,
    required this.phone,
  }) : super(key: key);

  @override
  State<VerifyPhoneChangePage> createState() => _VerifyPhoneChangePageState();
}

class _VerifyPhoneChangePageState extends State<VerifyPhoneChangePage> {
  late TextEditingController _otpController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Verifikasi Nomor Handphone',
        onLeadingPressed: () => context.pop(),
      ),
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            // Update auth session
            context.read<AuthSessionCubit>().updateUser(state.user);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Pop back to account page
            context.pop();
            context.pop();
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
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kode verifikasi telah dikirim ke',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    color: AppColors.grayColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phone,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Kode Verifikasi',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    counterText: '',
                  ),
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 8,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode verifikasi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kode verifikasi harus 6 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;
                    
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleVerify,
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
                              'Verifikasi',
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

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileUpdateCubit>().verifyPhoneUpdate(
            userId: widget.userId,
            newPhone: widget.phone,
            verificationCode: _otpController.text,
          );
    }
  }
}