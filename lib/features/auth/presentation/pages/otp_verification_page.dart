// lib/features/auth/presentation/pages/otp_verification_page.dart
import 'dart:async';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Controllers
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();

  // State
  bool _hasError = false;
  String _currentOtp = '';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Auto focus setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _pinFocusNode.dispose();
    _errorController.close();
    super.dispose();
  }

  void _verifyOtp() {
    if (_currentOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan kode OTP'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }

    print(
      '🔄 Verifying OTP: $_currentOtp (${_currentOtp.length} digits) for ${widget.phoneNumber}',
    );

    context.read<AuthBloc>().add(
          VerifyOtpEvent(widget.phoneNumber, _currentOtp),
        );
  }

  void _resendOtp() {
    // Clear error dan input
    setState(() {
      _hasError = false;
      _currentOtp = '';
    });
    _otpController.clear();

    print('🔄 Resending OTP for ${widget.phoneNumber}');

    // Request OTP baru
    context.read<AuthBloc>().add(RequestOtpEvent(widget.phoneNumber));

    // Start timer countdown - HANYA SAAT RESEND
    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
  }

  void _showOtpError() {
    setState(() {
      _hasError = true;
    });

    // Trigger shake animation
    _errorController.add(ErrorAnimationType.shake);

    // Clear input setelah shake animation selesai
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _otpController.clear();
      setState(() {
        _currentOtp = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(153),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              icon: const Icon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
              ),
              onPressed: () {
                if (!_isNavigating) {
                  // Reset timer saat back
                  context.read<OtpTimerBloc>().add(ResetOtpTimer());
                  context.pop();
                }
              },
            ),
          ),
          flexibleSpace: SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Verifikasi Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masukkan kode OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            print('✅ OTP Verified Successfully for ${widget.phoneNumber}');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ OTP berhasil diverifikasi!'),
                backgroundColor: Colors.green,
              ),
            );

            // Reset timer
            context.read<OtpTimerBloc>().add(ResetOtpTimer());

            // Navigate ke halaman selanjutnya
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              _isNavigating = false;

              // TODO: Ganti dengan route yang sesuai
              // Misalnya ke halaman form registrasi lengkap
              // context.push('/register-form', extra: widget.phoneNumber);

              // Atau langsung ke home jika sudah terdaftar
              context.go('/home');
            });
          } else if (state is OtpVerificationError) {
            print('❌ OTP Verification Failed: ${state.message}');
            _showOtpError();
          } else if (state is OtpRequestSuccess) {
            print('📱 New OTP sent: ${state.otp}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📱 Kode OTP baru: ${state.otp}'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // PIN CODE FIELDS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _otpController,
                        focusNode: _pinFocusNode,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        autoFocus: false,

                        // Error animation controller
                        errorAnimationController: _errorController,

                        // Text styling
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primaryFont,
                        ),

                        // Pin theme
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 56,
                          fieldWidth: 56,
                          fieldOuterPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),

                          // Active state (currently typing)
                          activeFillColor: Colors.white,
                          activeColor: const Color(0xFF2196F3),
                          activeBorderWidth: 2,

                          // Selected state (focused but empty)
                          selectedFillColor: Colors.white,
                          selectedColor: const Color(0xFF2196F3),
                          selectedBorderWidth: 2,

                          // Inactive state (not focused)
                          inactiveFillColor: Colors.grey[100],
                          inactiveColor: AppColors.grayColor.withOpacity(0.3),
                          inactiveBorderWidth: 1.5,

                          // Error state
                          errorBorderColor: AppColors.primaryColor,
                          errorBorderWidth: 2,
                        ),

                        // On change callback
                        onChanged: (value) {
                          // Clear error saat user mulai input lagi
                          if (_hasError && value.isNotEmpty) {
                            setState(() {
                              _hasError = false;
                            });
                          }
                          setState(() {
                            _currentOtp = value;
                          });
                        },

                        // On completed callback
                        onCompleted: (value) {
                          print('OTP completed: $value');
                          // User tetap harus klik "Selanjutnya"
                          // Tidak auto verify
                        },

                        // Paste validation
                        beforeTextPaste: (text) {
                          print("Pasting text: $text");
                          // Allow paste jika text adalah angka
                          return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Error message dengan fade animation
                    AnimatedOpacity(
                      opacity: _hasError ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'OTP salah !',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Resend Code Section
                    _buildResendSection(),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: (isLoading || _isNavigating) ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey[300],
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Selanjutnya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return BlocBuilder<OtpTimerBloc, OtpTimerState>(
      builder: (context, timerState) {
        if (timerState is OtpTimerRunning) {
          // Timer sedang berjalan
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim ulang dalam ${timerState.formattedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (timerState is OtpTimerCompleted ||
            timerState is OtpTimerInitial) {
          // Timer completed atau belum dimulai
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      'Kirim Ulang Kode',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}