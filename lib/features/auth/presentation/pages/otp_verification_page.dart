// lib/features/auth/presentation/pages/otp_verification_page.dart
import 'dart:async';

import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // new: focus node for PinCodeTextField
  final FocusNode _pinFocusNode = FocusNode();

  // Error state + timer/controller for animation
  bool _hasError = false;
  String _currentOtp = '';
  bool _isNavigating = false;
  bool _suppressOnChanged = false;

  // StreamController required by pin_code_fields for error animation (shake)
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();

  // Timer to control how long the error message remains visible
  Timer? _errorDisplayTimer;

  @override
  void initState() {
    super.initState();
    // Request focus safely after first frame (guard mounted)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Only request focus if you want user to focus automatically
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _pinFocusNode.dispose();
    _errorController.close();
    _errorDisplayTimer?.cancel();
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
    // Clear error state
    _clearErrorState();

    // Clear OTP input
    _otpController.clear();

    print('🔄 Resending OTP for ${widget.phoneNumber}');

    // Request OTP baru
    context.read<AuthBloc>().add(RequestOtpEvent(widget.phoneNumber));

    // Start timer countdown - HANYA SAAT RESEND
    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
  }

  // Show error with shake + keep error message visible for some time
  void _showOtpError({String? message}) {
    // cancel existing timer if any
    _errorDisplayTimer?.cancel();

    setState(() {
      _hasError = true;
    });

    // trigger shake animation
    _errorController.add(ErrorAnimationType.shake);

    // keep the error shown for 2.5 seconds, then hide
    _errorDisplayTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _hasError = false;
      });
    });
  }

  void _clearErrorState() {
    _errorDisplayTimer?.cancel();
    if (mounted) {
      setState(() {
        _hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final yellowColor = const Color(0xFFFDD100);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(153),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is OtpVerificationSuccess) {
                if (_isNavigating) return;
                _isNavigating = true;

                print('✅ OTP Verified Successfully for ${widget.phoneNumber}');

                // OTP berhasil diverifikasi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ OTP berhasil diverifikasi!'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Reset timer
                context.read<OtpTimerBloc>().add(ResetOtpTimer());

                // Navigate ke halaman selanjutnya (Register Form atau Home)
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

                // Show error with shake animation and keep message visible
                _showOtpError();

                // Clear OTP input setelah error (sedikit delay supaya user melihat shake)
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (!mounted) return;

                  // tandai perubahan programatik supaya onChanged tidak membatalkan error
                  _suppressOnChanged = true;
                  _otpController.clear();

                  // beri sedikit waktu untuk PinCodeTextField memproses clear, lalu restore flag
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (!mounted) return;
                    _suppressOnChanged = false;
                    setState(() {
                      _currentOtp = '';
                    });
                  });
                });
              } else if (state is OtpRequestSuccess) {
                // OTP baru berhasil dikirim (untuk resend)
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
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  // horizontal: 80,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // PIN CODE FIELDS
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            animationDuration: const Duration(
                              milliseconds: 300,
                            ),
                            enableActiveFill: true,
                            autoFocus: false,
                            focusNode: _pinFocusNode,

                            // Provide the errorAnimationController to trigger shakes
                            errorAnimationController: _errorController,

                            // Validator: when _hasError is true, return a message so field shows error state
                            validator: (value) {
                              // Returning non-null string triggers error visuals in the field
                              return _hasError ? 'OTP salah' : null;
                            },

                            // show validation result immediately so border becomes red right away
                            autovalidateMode: AutovalidateMode.always,

                            // Styling
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.primaryFont,
                            ),

                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 56,
                              fieldWidth: 56,

                              fieldOuterPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),

                              // Active (currently typing)
                              activeFillColor: Colors.white,
                              activeColor: const Color(0xFF2196F3),
                              activeBorderWidth: 2,

                              // Selected (focused but empty)
                              selectedFillColor: Colors.white,
                              selectedColor: const Color(0xFF2196F3),
                              selectedBorderWidth: 2,

                              // Inactive (not focused)
                              inactiveFillColor: Colors.grey[100],
                              inactiveColor: AppColors.grayColor.withOpacity(
                                0.3,
                              ),
                              inactiveBorderWidth: 1.5,

                              // Error state (warna border saat validator mengembalikan teks)
                              errorBorderColor: AppColors.primaryColor,
                              errorBorderWidth: 2,
                            ),

                            onChanged: (value) {
                              // jika perubahan berasal dari kode (mis. _otpController.clear()), abaikan
                              if (_suppressOnChanged) {
                                // tetap update current otp jika perlu, tetapi jangan hapus error/timer
                                setState(() {
                                  _currentOtp = value;
                                });
                                return;
                              }

                              // ketika user mulai mengetik lagi, hilangkan error dan batalkan timer
                              _errorDisplayTimer?.cancel();
                              if (_hasError) {
                                setState(() {
                                  _hasError = false;
                                });
                              }
                              setState(() {
                                _currentOtp = value;
                              });
                            },

                            onCompleted: (value) {
                              print('OTP completed: $value');
                              // Tidak auto verify; user tetap menekan tombol Selanjutnya
                            },

                            beforeTextPaste: (text) {
                              print("Pasting text: $text");
                              // Allow paste jika text adalah angka
                              return text?.contains(RegExp(r'^[0-9]+$')) ??
                                  false;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Error message (kustom) - ditampilkan ketika _hasError true
                      if (_hasError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              // Text(
                              //   'OTP salah !',
                              //   style: TextStyle(
                              //     color: Colors.red,
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                      // Resend Code Section
                      _buildResendSection(),
                    ],
                  ),
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
                      backgroundColor: yellowColor,
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
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(fontSize: 14, color: AppColors.grayColor),
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
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(fontSize: 14, color: AppColors.grayColor),
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
