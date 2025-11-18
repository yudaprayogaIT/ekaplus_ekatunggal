// lib/features/auth/presentation/pages/otp_verification_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';

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
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  bool _hasError = false;
  String _errorMessage = '';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Auto focus ke input pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  bool get _isOtpComplete {
    return _otpCode.length == 6;
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _verifyOtp() {
    if (_isOtpComplete) {
      print('🔄 Verifying OTP: $_otpCode for ${widget.phoneNumber}');
      context.read<AuthBloc>().add(
            VerifyOtpEvent(widget.phoneNumber, _otpCode),
          );
    }
  }

  void _resendOtp() {
    // Clear error state
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    // Clear OTP input
    _clearOtp();

    print('🔄 Resending OTP for ${widget.phoneNumber}');

    // Request OTP baru
    context.read<AuthBloc>().add(RequestOtpEvent(widget.phoneNumber));

    // Start timer countdown - HANYA SAAT RESEND
    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
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
                        fontWeight: FontWeight.w500, fontFamily: AppFonts.primaryFont,
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
                
                setState(() {
                  _hasError = true;
                  _errorMessage = 'OTP salah !';
                });
                _clearOtp();
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // OTP Input Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildOtpBox(index),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Resend Code Section
                    _buildResendSection(),

                    const Spacer(),

                    // Button Selanjutnya
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return ElevatedButton(
                          onPressed: (isLoading || !_isOtpComplete || _isNavigating)
                              ? null
                              : _verifyOtp,
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

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _hasError 
              ? AppColors.primaryColor 
              : AppColors.grayColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.primaryFont,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          setState(() {
            _hasError = false;
            _errorMessage = '';
          });

          if (value.isNotEmpty) {
            // Auto move ke box selanjutnya
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Semua box terisi, unfocus (TIDAK auto verify)
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Backspace, pindah ke box sebelumnya
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return BlocBuilder<OtpTimerBloc, OtpTimerState>(
      builder: (context, timerState) {
        if (timerState is OtpTimerRunning) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tidak dapat kode ? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                  Text(
                    'Kirim ulang dalam ${timerState.formattedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (timerState is OtpTimerCompleted ||
            timerState is OtpTimerInitial) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tidak dapat kode ? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayColor,
                ),
              ),
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
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}