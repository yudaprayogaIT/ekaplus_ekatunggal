import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int otpLength = 6;

  // controllers & focus nodes untuk tiap kotak
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());
    // set fokus awal ke kotak pertama ketika halaman muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp {
    return _controllers.map((c) => c.text).join();
  }

  void _submitOtpIfComplete() {
    final code = _currentOtp;
    if (code.length == otpLength && !code.contains('')) {
      // panggil bloc verify
      context.read<AuthBloc>().add(VerifyOtpEvent(widget.phone, code));
    }
  }

  void _handleInput(int index, String value) async {
    // ambil hanya digit
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      // user hapus; pindah fokus ke sebelumnya
      if (_controllers[index].text.isEmpty) {
        // sudah kosong, pindah ke previous dan clear
        if (index - 1 >= 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index - 1].text.length),
          );
        }
      } else {
        // normal clear current (happens automatically)
      }
      return;
    }

    // Jika user mem-paste lebih dari 1 char (misal '1234'), distribusikan
    if (digits.length > 1) {
      _handlePaste(digits, startIndex: index);
      return;
    }

    // Single digit input
    _controllers[index].text = digits;
    // setelah memasukkan, pindah fokus ke kotak berikutnya
    if (index + 1 < otpLength) {
      _focusNodes[index + 1].requestFocus();
      _controllers[index + 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index + 1].text.length),
      );
    } else {
      // jika di kotak terakhir -> lepas fokus keyboard
      _focusNodes[index].unfocus();
    }

    // jika lengkap, submit
    if (_currentOtp.length == otpLength && !_currentOtp.contains('')) {
      _submitOtpIfComplete();
    }
  }

  void _handlePaste(String pasted, {int startIndex = 0}) {
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');
    for (var i = 0; i < digits.length && (startIndex + i) < otpLength; i++) {
      _controllers[startIndex + i].text = digits[i];
    }

    // set focus ke next empty or unfocus if complete
    final firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
    if (firstEmpty != -1) {
      _focusNodes[firstEmpty].requestFocus();
    } else {
      // semua terisi
      _focusNodes.last.unfocus();
      _submitOtpIfComplete();
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.grayColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onChanged: (value) => _handleInput(index, value),
        onTap: () {
          // jika user men-tap dan ada text, letakkan cursor di akhir
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
        // support paste from keyboard/menu: detect via onChanged where value.length>1 handled
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFB11F23);
    final yellowColor = const Color(0xFFFDD100);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(153),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
              onPressed: () => context.pop(),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP Berhasil! Lanjut ke Registrasi.'),
                backgroundColor: Colors.green,
              ),
            );
            // TODO: navigasi ke halaman form registrasi
          } else if (state is OtpVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OtpRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP baru terkirim. (DEBUG: ${state.otp})'),
                backgroundColor: Colors.blue,
              ),
            );
            // Jika OTP dikirim ulang, kita bisa auto-isi debug OTP jika mau:
            // _handlePaste(state.otp);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Masukkan Kode OTP yang dikirim ke ${widget.phone}'),
              const SizedBox(height: 20),
              // Row kotak OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(otpLength, (i) => _buildOtpBox(i)),
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
                      backgroundColor: yellowColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            // ambil kode dari boxes
                            final code = _currentOtp;
                            if (code.length == otpLength) {
                              context.read<AuthBloc>().add(
                                    VerifyOtpEvent(widget.phone, code),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lengkapi kode OTP terlebih dahulu'),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
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
