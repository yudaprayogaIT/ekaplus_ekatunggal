import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';

// Ganti dengan rute ke halaman Register Form
// import 'register_form_page.dart'; 

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Tampilan UI dari gambar Anda
    //  
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Akun')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            // Navigasi ke halaman Register Form
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP Berhasil! Lanjut ke Registrasi.'),
                backgroundColor: Colors.green,
              ),
            );
            // Ganti dengan navigasi sebenarnya:
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => RegisterFormPage(phone: state.phone),
            //   ),
            // );
          } else if (state is OtpVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OtpRequestSuccess) {
             // Handle jika user klik "Kirim Ulang Kode"
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'OTP baru terkirim. (DEBUG: ${state.otp})'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Masukkan Kode OTP yang dikirim ke ${widget.phone}'),
              const SizedBox(height: 20),
              // Simulasi input OTP 6 digit
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4, // Sesuai dengan OtpModel (4 digit)
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  labelText: 'Kode OTP (Contoh: 1234)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Kirim Ulang Kode OTP
                    context.read<AuthBloc>().add(RequestOtpEvent(widget.phone));
                  },
                  child: const Text('Kirim Ulang Kode'),
                ),
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  bool isLoading = state is AuthLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEEA9A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_otpController.text.isNotEmpty) {
                              context.read<AuthBloc>().add(
                                    VerifyOtpEvent(
                                        widget.phone, _otpController.text),
                                  );
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Selanjutnya',
                            style: TextStyle(color: Colors.black),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}