// lib/features/auth/presentation/pages/login_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isNavigating = false;
  bool _isDisposed = false;
  String? _identifierError;
  String? _passwordError;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _identifierController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    if (!mounted || _isDisposed) return;
    _shakeController.forward(from: 0).then((_) {
      if (mounted && !_isDisposed) {
        _shakeController.reverse();
      }
    });
  }

  String? _validateIdentifier(String? value) {
    if (_identifierError != null) {
      return _identifierError;
    }

    if (value == null || value.isEmpty) {
      return 'Nomor HP atau username tidak boleh kosong';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (_passwordError != null) {
      return _passwordError;
    }

    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    return null;
  }

  void _onLoginPressed() {
    if (!mounted || _isDisposed) return;

    setState(() {
      _identifierError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      context.read<AuthBloc>().add(
            LoginUserEvent(identifier: identifier, password: password),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final yellowColor = const Color(0xFFFDD100);
    final contentHeight = MediaQuery.of(context).size.height - 240;

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
                if (!_isNavigating && !_isDisposed) {
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
                      'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Masukkan nomor handphone/username dan password Anda',
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
          if (!mounted || _isDisposed) return;

          if (state is LoginError) {
            print('❌ Login Error: ${state.message}');

            setState(() {
              if (state.message.contains('tidak ditemukan')) {
                _identifierError = state.message;
                _passwordError = null;
              } else if (state.message.contains('salah')) {
                _identifierError = null;
                _passwordError = state.message;
              } else {
                _identifierError = state.message;
                _passwordError = null;
              }
            });

            _formKey.currentState!.validate();
            _triggerShake();
          } else if (state is LoginSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            print('✅ Login Success: ${state.user.fullName}');

            // 🔥 PENTING: Unfocus keyboard dulu
            FocusScope.of(context).unfocus();

            // 🔥 NEW: Save session via AuthSessionCubit
            context.read<AuthSessionCubit>().login(state.user);

            if (mounted && !_isDisposed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selamat datang, ${state.user.fullName}! 👋'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            // Navigate after frame completion
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _isDisposed) return;
              context.go('/');
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: contentHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            // Identifier Input
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: 'Nomor Hp/Username',
                                  hintText: 'Masukkan nomor HP atau username',
                                  labelStyle: TextStyle(
                                    color: _identifierError != null
                                        ? AppColors.primaryColor
                                        : AppColors.grayColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone_android,
                                    color: _identifierError != null
                                        ? AppColors.primaryColor
                                        : AppColors.grayColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _identifierError != null
                                          ? AppColors.primaryColor
                                          : AppColors.grayColor.withOpacity(0.5),
                                      width: _identifierError != null ? 2 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _identifierError != null
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
                                validator: _validateIdentifier,
                                onChanged: (value) {
                                  if (_identifierError != null && mounted && !_isDisposed) {
                                    setState(() {
                                      _identifierError = null;
                                    });
                                    _formKey.currentState?.validate();
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password Input
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Masukkan password',
                                  labelStyle: TextStyle(
                                    color: _passwordError != null
                                        ? AppColors.primaryColor
                                        : AppColors.grayColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: _passwordError != null
                                        ? AppColors.primaryColor
                                        : AppColors.grayColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.grayColor,
                                    ),
                                    onPressed: () {
                                      if (mounted && !_isDisposed) {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      }
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _passwordError != null
                                          ? AppColors.primaryColor
                                          : AppColors.grayColor.withOpacity(0.5),
                                      width: _passwordError != null ? 2 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: _passwordError != null
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
                                validator: _validatePassword,
                                onChanged: (value) {
                                  if (_passwordError != null && mounted && !_isDisposed) {
                                    setState(() {
                                      _passwordError = null;
                                    });
                                    _formKey.currentState?.validate();
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Forgot Password Section (same as before)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur Lupa Password segera hadir'),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa password ?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grayColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur Lupa Password segera hadir'),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa Password',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(thickness: 0.8, color: Colors.black26),
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
                                  child: Divider(thickness: 0.8, color: Colors.black26),
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
                                'Google',
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
                                foregroundColor: Colors.black,
                              ),
                            ),

                            const Spacer(),

                            // Login Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;

                                return ElevatedButton(
                                  onPressed: (isLoading || _isNavigating || _isDisposed)
                                      ? null
                                      : _onLoginPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: yellowColor,
                                    foregroundColor: Colors.black,
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
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun?  ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (!_isNavigating && !_isDisposed) {
                                      context.push('/register');
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Daftar Sekarang',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}