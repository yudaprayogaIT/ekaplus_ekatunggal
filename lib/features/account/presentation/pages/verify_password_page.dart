// lib/features/account/presentation/pages/verify_password_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyPasswordPage extends StatefulWidget {
  final String userId;
  final String title;
  final String subtitle;
  final String nextRoute;
  final Map<String, dynamic>? nextRouteExtra;

  const VerifyPasswordPage({
    Key? key,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.nextRoute,
    this.nextRouteExtra,
  }) : super(key: key);

  @override
  State<VerifyPasswordPage> createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends State<VerifyPasswordPage> {
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: widget.title,
        onLeadingPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Password Field
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
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grayColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed('forgot-password-phone');
                  },
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Submit Button
              ElevatedButton(
                onPressed: _isVerifying ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.secondaryColor,
                  disabledBackgroundColor: AppColors.secondaryColor.withOpacity(
                    0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.whiteColor,
                          ),
                        ),
                      )
                    : Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
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

  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text;

      setState(() {
        _isVerifying = true;
      });

      try {
        // Verify password using local datasource
        final localDataSource = myinjection<AuthLocalDataSource>();
        final user = await localDataSource.getUserByPhone(widget.userId);

        if (user == null) {
          throw Exception('User tidak ditemukan');
        }

        // Check password
        if (user.password != password) {
          setState(() {
            _isVerifying = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password salah'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Password correct, navigate to next route
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });

          final extra = widget.nextRouteExtra ?? {};
          extra['password'] = password; // Pass verified password
          extra['userId'] = widget.userId;

          // ← ADD TYPE DETECTION
          // If nextRouteExtra contains 'currentPhone' or 'currentEmail',
          // it means we're editing contact info
          if (widget.nextRoute == 'edit-contact') {
            // Type is already in extra from AccountLoggedInView
            // Just keep it as is
          }

          context.pushNamed(widget.nextRoute, extra: extra);
        }
      } catch (e) {
        setState(() {
          _isVerifying = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
