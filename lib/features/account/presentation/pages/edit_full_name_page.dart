// lib/features/account/presentation/pages/edit_full_name_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditFullNamePage extends StatefulWidget {
  final String userId;
  final String currentName;

  const EditFullNamePage({
    Key? key,
    required this.userId,
    required this.currentName,
  }) : super(key: key);

  @override
  State<EditFullNamePage> createState() => _EditFullNamePageState();
}

class _EditFullNamePageState extends State<EditFullNamePage> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Ubah Nama Lengkap',
        onLeadingPressed: () => context.pop(),
      ),
      body: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            // Update auth session with new user data
            context.read<AuthSessionCubit>().updateUser(state.user);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nama Lengkap',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama lengkap minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<ProfileUpdateCubit, ProfileUpdateState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdateLoading;
                    
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Simpan',
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      if (newName != widget.currentName) {
        context.read<ProfileUpdateCubit>().updateName(
              userId: widget.userId,
              fullName: newName,
            );
      } else {
        context.pop();
      }
    }
  }
}