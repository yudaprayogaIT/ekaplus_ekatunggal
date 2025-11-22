// lib/features/auth/presentation/pages/register_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isNavigating = false;
  String? _phoneErrorMessage; // Custom error message
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
  }

  String? _validatePhone(String? value) {
    // Return custom error if exists
    if (_phoneErrorMessage != null) {
      return _phoneErrorMessage;
    }

    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    if (cleanPhone.length > 13) {
      return 'Nomor telepon maksimal 13 digit';
    }

    if (!cleanPhone.startsWith('0') && !cleanPhone.startsWith('62')) {
      return 'Nomor harus diawali 0 atau 62';
    }

    return null;
  }

  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    }

    return cleaned;
  }

  void _onNextPressed() {
    // Clear previous error
    setState(() {
      _phoneErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final normalizedPhone = _normalizePhone(_phoneController.text);
      print('🔄 Checking phone: $normalizedPhone');
      context.read<AuthBloc>().add(CheckPhoneEvent(normalizedPhone));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final yellowColor = const Color(0xFFFDD100);

    return Scaffold(
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
                      'Daftar',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masukkan nomor handphone untuk aktivasi',
                      style: TextStyle(
                        color: AppColors.whiteColor,
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
          if (state is PhoneCheckSuccess) {
            if (state.exists) {
              // Phone already registered - show error
              print('⚠️ Phone already registered');
              setState(() {
                _phoneErrorMessage = 'Nomor ini sudah terdaftar. Silakan login atau gunakan nomor lain.';
              });
              _formKey.currentState!.validate(); // Trigger validation
              _triggerShake(); // Trigger shake animation
            } else {
              // Phone available - proceed to OTP
              final normalizedPhone = _normalizePhone(_phoneController.text);
              print('✅ Phone available, requesting OTP');
              context.read<AuthBloc>().add(RequestOtpEvent(normalizedPhone));
            }
          } else if (state is PhoneCheckError) {
            print('❌ Phone Check Error: ${state.message}');
            setState(() {
              _phoneErrorMessage = state.message;
            });
            _formKey.currentState!.validate();
            _triggerShake();
          } else if (state is OtpRequestSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            print('✅ OTP Generated (6 digit): ${state.otp}');
            print('📱 Phone: ${state.phone}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📱 Kode OTP 6 digit: ${state.otp}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              _isNavigating = false;
              context.push('/otp', extra: state.phone);
            });
          } else if (state is OtpRequestError) {
            print('❌ OTP Request Error: ${state.message}');
            setState(() {
              _phoneErrorMessage = state.message;
            });
            _formKey.currentState!.validate();
            _triggerShake();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Phone Input Field with Shake Animation
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(13),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Nomor Hp',
                            hintText: 'Contoh: 0812xxx atau 62812xxxx',
                            labelStyle: TextStyle(
                              color: _phoneErrorMessage != null 
                                  ? AppColors.primaryColor 
                                  : AppColors.grayColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: _phoneErrorMessage != null 
                                  ? AppColors.primaryColor 
                                  : AppColors.grayColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _phoneErrorMessage != null 
                                    ? AppColors.primaryColor 
                                    : AppColors.grayColor,
                                width: _phoneErrorMessage != null ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _phoneErrorMessage != null 
                                    ? AppColors.primaryColor 
                                    : const Color(0xFF2196F3),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          validator: _validatePhone,
                          onChanged: (value) {
                            // Clear error when user types or deletes
                            if (_phoneErrorMessage != null) {
                              setState(() {
                                _phoneErrorMessage = null;
                              });
                              // Revalidate to clear error border
                              _formKey.currentState?.validate();
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // // Info text or error message
                      // AnimatedSwitcher(
                      //   duration: const Duration(milliseconds: 300),
                      //   child: _phoneErrorMessage == null
                      //       ? const Text(
                      //           'Kami akan mengirimkan kode OTP 6 digit ke nomor ini',
                      //           key: ValueKey('info'),
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             color: AppColors.grayColor,
                      //           ),
                      //         )
                      //       : Text(
                      //           _phoneErrorMessage!,
                      //           key: ValueKey('error'),
                      //           style: const TextStyle(
                      //             fontSize: 12,
                      //             color: AppColors.primaryColor,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      // ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.black26,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grayColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.black26,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Google Sign In Button
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google Sign In belum tersedia'),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/icons/google.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, size: 24);
                          },
                        ),
                        label: const Text(
                          'Daftar dengan Google',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            color: AppColors.grayColor,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(
                            color: AppColors.grayColor,
                            width: 1.5,
                          ),
                          foregroundColor: AppColors.blackColor,
                        ),
                      ),

                      const Spacer(),

                      // Next Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return ElevatedButton(
                            onPressed: (isLoading || _isNavigating)
                                ? null
                                : _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: yellowColor,
                              foregroundColor: AppColors.blackColor,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.blackColor,
                                    ),
                                  )
                                : const Text(
                                    'Selanjutnya',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              if (!_isNavigating) {
                                context.push('/login');
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}