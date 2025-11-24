// lib/features/account/presentation/pages/account_page.dart
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_guest_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_logged_in_view.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/widgets/account_others_section.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        title: 'Akun',
        onLeadingPressed: () => context.goNamed('home'),
      ),
      body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, state) {
          if (state is AuthSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthSessionAuthenticated) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile section when logged in
                  AccountLoggedInView(user: state.user),

                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.whiteColor,
                  ),

                  // Others section
                  const AccountOthersSection(),
                ],
              ),
            );
          }

          // Guest view
          return const SingleChildScrollView(
            child: Column(
              children: [
                // Guest promotion section
                AccountGuestView(),

                SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

                // Others section
                AccountOthersSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
