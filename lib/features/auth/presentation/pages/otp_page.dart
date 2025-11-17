import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// Asumsi 'ekaplus_ekatunggal/constant.dart' ada
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';


class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> { // Hapus SingleTickerProviderStateMixin
  final TextEditingController _pinController = TextEditingController();
  
  bool _isNavigating = false;
  // bool _isShaking = false; // Dihapus
  
  // Semua variabel Cooldown Timer Dihapus
  // Timer? _cooldownTimer;
  // int _cooldownSeconds = 0;
  // int _resendAttempt = 0;
  
  // Semua Cooldown durations Dihapus
  // static const int _firstCooldown = 60; 
  // static const int _secondCooldown = 180; 
  // static const int _thirdCooldown = 300; 
  
  // Semua Shake Animation Dihapus
  // late AnimationController _shakeController;
  // late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Shake Animation Dihapus
    // _shakeController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 500),
    // );
    
    // _shakeAnimation = Tween<double>(
    //   begin: 0,
    //   end: 10,
    // ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _pinController.dispose();
    // _cooldownTimer?.cancel(); // Dihapus
    // _shakeController.dispose(); // Dihapus
    super.dispose();
  }

  // Fungsi _getCooldownDuration Dihapus
  // int _getCooldownDuration(int attempt) { ... }

  // Fungsi _startCooldown Dihapus
  // void _startCooldown() { ... }

  // Fungsi _formatCooldown Dihapus
  // String _formatCooldown() { ... }

  // Fungsi _playShakeAnimation Dihapus
  // void _playShakeAnimation() { ... }

  // Fungsi _onResendOtp Dihapus total, karena fitur resend dihilangkan
  void _onResendOtp() {
    // Fungsi ini dikosongkan/dihapus, tetapi biarkan agar TextButton yang dinonaktifkan di bawah tidak error
  }


  @override
  Widget build(BuildContext context) {
    // print('🔄 Building OTP Page - ...'); // Dihapus

    final primaryColor = AppColors.primaryColor;
    final yellowColor = const Color(0xFFFDD100);
    // final isCooldownActive = _cooldownSeconds > 0; // Dihapus

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
                      'Verifikasi Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masukkan kode OTP 6 digit',
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
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ OTP Berhasil! Lanjut ke Registrasi.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );

            // Navigate to next screen
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              _isNavigating = false;
              // Gunakan pop() untuk kembali ke halaman sebelumnya (RegisterPhone)
              context.pop(); 
              // *Anda mungkin ingin menavigasi ke halaman RegisterForm di sini*
            });
          } else if (state is OtpVerificationError) {
            // _playShakeAnimation(); // Dihapus
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          } 
          // Logika OtpRequestSuccess dan OtpRequestError Dihapus/Dibersihkan
          else if (state is OtpRequestSuccess) {
            print('✅ OTP Request Success.');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📩 OTP baru dikirim (DEBUG: ${state.otp})'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
            
            _pinController.clear();
            
            // Logika _startCooldown() dihapus
          } else if (state is OtpRequestError) {
            // Logika rollback attempt, timer cancel, dan cooldown reset Dihapus
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masukkan Kode OTP 6 digit yang dikirim ke\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grayColor,
                ),
              ),
              const SizedBox(height: 30),

              // AnimatedBuilder (Shake Animation) Dihapus
              PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                controller: _pinController,
                keyboardType: TextInputType.number,
                autoFocus: true,
                enableActiveFill: true,
                animationDuration: const Duration(milliseconds: 200),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 55,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: const Color(0xFF2196F3),
                  selectedColor: primaryColor,
                  inactiveColor: AppColors.grayColor,
                  errorBorderColor: Colors.red,
                  borderWidth: 2,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                onChanged: (value) {},
              ),

              const SizedBox(height: 20),

              // Bagian Kirim Ulang Kode (Resend OTP)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tidak menerima kode?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grayColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Tombol Kirim Ulang Dihapus dan diganti dengan placeholder
                    TextButton(
                      // onPressed: _onResendOtp, // Dihapus
                      onPressed: null, // Dinonaktifkan total
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Kirim Ulang Kode (Dinonaktifkan)',
                        style: TextStyle(
                          color: AppColors.grayColor, // Selalu abu-abu
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Submit Button
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) {
                  return (previous is! AuthLoading && current is AuthLoading) ||
                              (previous is AuthLoading && current is! AuthLoading);
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  
                  return ElevatedButton(
                    onPressed: (isLoading || _isNavigating /*|| _isShaking*/)
                        ? null
                        : () {
                            final code = _pinController.text.trim();
                            if (code.length == 6) {
                              context.read<AuthBloc>().add(
                                    VerifyOtpEvent(widget.phone, code),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lengkapi kode OTP 6 digit terlebih dahulu',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Help Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Butuh bantuan? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hubungi support: support@ekaplus.com'),
                        ),
                      );
                    },
                    child: const Text(
                      'Kontak Kami',
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
    );
  }
}