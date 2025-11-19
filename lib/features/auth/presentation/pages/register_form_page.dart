// lib/features/auth/presentation/pages/register_form_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/services/storage_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/dev_tools/dev_tools.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RegisterFormPage extends StatefulWidget {
  final String phoneNumber;

  const RegisterFormPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isNavigating = false;

  Widget _buildResponsivePair(
    Widget left,
    Widget right, {
    double spacing = 12,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Anda bisa tweak breakpoint ini (600 = tablet-ish)
        const double breakpoint = 440;
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left field
              Expanded(child: left),
              SizedBox(width: spacing),
              // Right field
              Expanded(child: right),
            ],
          );
        } else {
          // Narrow screen: tumpuk vertikal (mirip behavior sebelumnya)
          return Column(children: [left, SizedBox(height: 12), right]);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_updateFullName);
    _lastNameController.addListener(_updateFullName);

    // Add listener untuk real-time password validation UI
    _passwordController.addListener(() {
      setState(() {}); // Rebuild untuk update password requirements
    });
  }

  void _updateFullName() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Auto-generate full name (real-time, tidak di-capitalize di UI)
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      _fullNameController.text = '$firstName $lastName'.trim();
    } else {
      _fullNameController.text = '';
    }
  }

  // Helper: Capitalize each word (untuk save ke DB)
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Helper: Trim dan remove multiple spaces
  String _cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Auto-copy JSON to clipboard
  Future<void> _autoCopyJsonToClipboard(BuildContext context) async {
    try {
      final storageService = StorageService();
      final jsonString = await storageService.exportUsersAsJson();

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonString));

      print('');
      print('✅ JSON AUTO-COPIED TO CLIPBOARD!');
      print('📋 You can now paste it anywhere');
      print('');
      print('📁 Also saved to: ${storageService.getAssetsFilePath()}');
      print('');
    } catch (e) {
      print('⚠️ Could not copy to clipboard: $e');
    }
  }

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }

    // Check if contains at least 1 digit OR 1 special character
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasDigit && !hasSpecialChar) {
      return 'Kata sandi harus mengandung minimal 1 angka atau simbol';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak sama';
    }
    return null;
  }

  // Date Picker
  Future<void> _selectBirthDate() async {
    final DateTime initial = _selectedDate ?? DateTime(2000);
    DateTime tempPicked = initial;

    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: Colors.white,
          child: Column(
            children: [
              // Toolbar dengan tombol "Batal" dan "Selesai"
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Batal'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text('Selesai'),
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempPicked;
                          _birthDateController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(_selectedDate!);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),

              // Divider tipis
              const Divider(height: 1),

              // CupertinoDatePicker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: DateTime(1950),
                  maximumDate: DateTime.now(),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime picked) {
                    // Simpan sementara; hanya dipakai saat user tekan "Selesai"
                    tempPicked = picked;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Submit Form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih jenis kelamin'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        return;
      }

      // Clean and capitalize data before saving
      final firstName = _capitalizeWords(_cleanText(_firstNameController.text));
      final lastName = _capitalizeWords(_cleanText(_lastNameController.text));
      final fullName = '$firstName $lastName'.trim();
      final birthPlace = _capitalizeWords(
        _cleanText(_birthPlaceController.text),
      );
      final email = _cleanText(_emailController.text).toLowerCase();
      final username = _usernameController.text.trim().isEmpty
          ? null
          : _cleanText(_usernameController.text).toLowerCase();

      print('📝 Registering user...');
      print('Phone: ${widget.phoneNumber}');
      print('First Name: $firstName (capitalized)');
      print('Last Name: $lastName (capitalized)');
      print('Full Name: $fullName (auto-generated)');
      print('Email: $email (lowercase)');
      print('Username: $username');
      print('Birth Place: $birthPlace (capitalized)');
      print('Birth Date: ${_birthDateController.text}');
      print('Gender: $_selectedGender');

      // Register user
      context.read<AuthBloc>().add(
        RegisterUserEvent(
          phone: widget.phoneNumber,
          firstName: firstName,
          lastName: lastName,
          username: username ?? '',
          email: email,
          dateOfBirth: _birthDateController.text,
          birthPlace: birthPlace,
          gender: _selectedGender!,
          password: _passwordController.text,
        ),
      );
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
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lengkapi Profil Anda',
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
          if (state is RegisterSuccess) {
            if (_isNavigating) return;
            _isNavigating = true;

            print('✅ Registration Success!');

            // Auto-copy JSON to clipboard
            _autoCopyJsonToClipboard(context);

            // Show success dialog (tidak hilang otomatis)
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    SizedBox(width: 12),
                    Text('Registrasi Berhasil!'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User berhasil didaftarkan: ${state.user.fullName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'JSON otomatis tersalin ke clipboard',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Data tersimpan di assets/data/users.json',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Anda bisa:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Paste JSON ke editor (sudah di clipboard)'),
                      const Text('• Lihat file di assets/data/users.json'),
                      const Text('• Export ulang via Dev Tools'),
                    ],
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DevToolsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('Lihat Dev Tools'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _isNavigating = false;
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK, Lanjutkan'),
                  ),
                ],
              ),
            );
          } else if (state is RegisterError) {
            print('❌ Registration Error: ${state.message}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryColor,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nama dan tempat lahir akan otomatis dikapitalkan saat disimpan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildResponsivePair(
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'Nama Depan',
                          hint: 'Masukkan nama depan',
                          validator: _validateName,
                        ),
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Nama Belakang',
                          hint: 'Masukkan nama belakang',
                          validator: _validateName,
                        ),
                      ),

                      // Full Name (Read Only - Auto Generated)
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        hint: 'Otomatis terisi',
                        readOnly: true,
                        enabled: false,
                      ),

                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Masukkan username',
                      ),
                      const SizedBox(height: 10),
                      _buildGenderDropdown(),
                      const SizedBox(height: 10),

                      _buildResponsivePair(
                        _buildTextField(
                          controller: _birthPlaceController,
                          label: 'Tempat Lahir',
                          hint: 'Masukkan tempat lahir',
                          validator: (value) =>
                              _validateRequired(value, 'Tempat lahir'),
                        ),
                        // Gunakan _buildDateField() yang ada sekarang (readOnly + onTap ke date picker)
                        _buildDateField(),
                      ),

                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Masukkan email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: TextEditingController(
                          text: widget.phoneNumber,
                        ),
                        label: 'Nomor Telepon',
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        obscureText: _obscurePassword,
                        onToggle: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Masukkan ulang kata sandi',
                        obscureText: _obscureConfirmPassword,
                        onToggle: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ElevatedButton(
                            onPressed: (isLoading || _isNavigating)
                                ? null
                                : _submitForm,
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
                                    'Simpan & Daftar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: AppColors.grayColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          hintStyle: const TextStyle(color: AppColors.grayColor, fontSize: 14),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grayColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
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
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: const TextStyle(
              color: AppColors.grayColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            hintStyle: const TextStyle(
              color: AppColors.grayColor,
              fontSize: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grayColor,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grayColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
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
          ),
        ),
        if (label == 'Kata Sandi')
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPasswordRequirement(
                  'Minimal 6 karakter',
                  controller.text.length >= 6,
                ),
                _buildPasswordRequirement(
                  'Mengandung angka atau simbol',
                  controller.text.contains(
                    RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      onTap: _selectBirthDate,
      validator: (value) => _validateRequired(value, 'Tanggal lahir'),
      decoration: InputDecoration(
        labelText: 'Tanggal Lahir',
        hintText: 'Pilih tanggal lahir',
        labelStyle: const TextStyle(
          color: AppColors.grayColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: AppColors.grayColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField2<String>(
      value: _selectedGender,
      isExpanded: true,

      // === styling form (tetap full) ===
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        labelStyle: const TextStyle(
          color: AppColors.grayColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),

      // hint: const Text('Pilih jenis kelamin'),
      items: const [
        DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
      ],

      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },

      validator: (value) {
        if (value == null) return 'Jenis kelamin tidak boleh kosong';
        return null;
      },

      // === bagian penting: atur ukuran popup dropdown ===
      dropdownStyleData: DropdownStyleData(
        // lebar popup (misal 260 px atau 70% layar)
        width: 260,
        // atau pakai maxWidth kalau mau adaptif:
        // maxWidth: 280,
        padding: const EdgeInsets.symmetric(vertical: 4),
      ),

      menuItemStyleData: const MenuItemStyleData(height: 48),

      iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down)),
    );
  }
}
