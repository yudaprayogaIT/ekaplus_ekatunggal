// lib/core/routes/my_router.dart
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/change_password_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/about_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/account_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/change_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_email_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_full_name_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_phone_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/new_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/select_avatar_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_email_change_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_password_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/verify_phone_number.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/change_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/reset_password_with_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_full_name.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_email_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_old_password.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_phone_change.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/forgot_password_phone_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/login_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_form_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_page.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/bloc/search_bloc.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/pages/search_page.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/products_highlight_page.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';

final getIt = GetIt.instance;

class MyRouter {
  GoRouter get router => GoRouter(
    // initialLocation: "/",
    // initialLocation: "/login",
    initialLocation: "/account",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            name: 'home',
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            name: 'category',
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            name: 'wishlist',
            path: '/wishlist',
            builder: (context, state) => const WishlistPage(),
          ),
        ],
      ),

      // ********** Routes tanpa bottom nav *********

      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterPage()),
      ),

      GoRoute(
        path: '/otp',
        name: 'otp',
        pageBuilder: (context, state) {
          // Get phone number from extra
          final phoneNumber = state.extra as String? ?? '';

          return MaterialPage(
            key: state.pageKey,
            child: OtpVerificationPage(phoneNumber: phoneNumber),
          );
        },
      ),

      // Register Form route (setelah OTP verified)
      GoRoute(
        path: '/registerForm',
        name: 'registerForm',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';

          return MaterialPage(
            key: state.pageKey,
            child: RegisterFormPage(phoneNumber: phoneNumber),
          );
        },
      ),

      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),

      GoRoute(
        name: 'account',
        path: '/account',
        builder: (context, state) {
          return AccountPage();
        },
      ),

      GoRoute(
        name: 'about',
        path: '/about',
        builder: (context, state) {
          return AboutPage();
        },
      ),

      GoRoute(
        path: '/select-avatar',
        name: 'selectAvatar',
        builder: (context, state) {
          final user = state.extra as User;
          return SelectAvatarPage(user: user);
        },
      ),

      GoRoute(
        name: 'search',
        path: '/search',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => SearchBloc(),
            child: const SearchPage(),
          );
        },
      ),

      GoRoute(
        name: 'categoryDetail',
        path: '/category/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryDetailPage(
            categoryId: id,
            categoryName: extra?['categoryName'],
            categoryTitle: extra?['categoryTitle'],
            categorySubtitle: extra?['categorySubtitle'],
          );
        },
      ),

      GoRoute(
        name: 'productPage',
        path: '/products',
        builder: (context, state) {
          final extra = state.extra as Category?;
          return ProductPage(categoryName: extra?.name, categoryId: extra?.id);
        },
      ),

      GoRoute(
        name: 'productDetail',
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),

      GoRoute(
        name: 'productsHighlight',
        path: '/products-highlight',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ProductsHighlight(
            hotDealsOnly: extra['hotDealsOnly'] ?? false,
            title: extra['title'] ?? 'Products',
            headerTitle: extra['headerTitle'] ?? '',
            headerSubTitle: extra['headerSubTitle'] ?? 'Products',
          );
        },
      ),

      // ============================================
      // ---------- PROFILE UPDATE ROUTES -----------
      // ============================================
      // 1. Edit Name (No password needed)
      GoRoute(
        path: '/account/edit-name',
        name: 'edit-name',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: EditFullNamePage(
              userId: extra['userId'] as String,
              currentName: extra['currentName'] as String,
            ),
          );
        },
      ),

      // 2. Verify Password Page (Reusable)
      GoRoute(
        path: '/account/verify-password',
        name: 'verify-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VerifyPasswordPage(
            userId: extra['userId'] as String,
            title: extra['title'] as String,
            subtitle: extra['subtitle'] as String,
            nextRoute: extra['nextRoute'] as String,
            nextRouteExtra: extra['nextRouteExtra'] as Map<String, dynamic>?,
          );
        },
      ),

      // 3. Edit Phone (After Password Verified)
      GoRoute(
        path: '/account/edit-phone-verified',
        name: 'edit-phone-verified',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: EditPhonePage(
              userId: extra['userId'] as String,
              currentPhone: extra['currentPhone'] as String,
              verifiedPassword: extra['password'] as String,
            ),
          );
        },
      ),

      // 4. Verify Phone Change (OTP) - Use BlocProvider.value
      GoRoute(
        path: '/account/verify-phone',
        name: 'verify-phone',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ProfileUpdateCubit?;

          // If cubit is passed, use BlocProvider.value
          if (cubit != null) {
            return BlocProvider<ProfileUpdateCubit>.value(
              value: cubit,
              child: VerifyPhoneChangePage(
                userId: extra['userId'] as String,
                phone: extra['phone'] as String,
              ),
            );
          }

          // Fallback: create new cubit (shouldn't happen)
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: VerifyPhoneChangePage(
              userId: extra['userId'] as String,
              phone: extra['phone'] as String,
            ),
          );
        },
      ),

      // 5. Edit Email (After Password Verified)
      GoRoute(
        path: '/account/edit-email-verified',
        name: 'edit-email-verified',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: EditEmailPage(
              userId: extra['userId'] as String,
              currentEmail: extra['currentEmail'] as String,
              verifiedPassword: extra['password'] as String,
            ),
          );
        },
      ),

      // 6. Verify Email Change (OTP) - Use BlocProvider.value
      GoRoute(
        path: '/account/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ProfileUpdateCubit?;

          // If cubit is passed, use BlocProvider.value
          if (cubit != null) {
            return BlocProvider<ProfileUpdateCubit>.value(
              value: cubit,
              child: VerifyEmailChangePage(
                userId: extra['userId'] as String,
                email: extra['email'] as String,
              ),
            );
          }

          // Fallback: create new cubit (shouldn't happen)
          return BlocProvider(
            create: (context) => ProfileUpdateCubit(
              updateFullName: getIt<UpdateFullName>(),
              requestPhoneChange: getIt<RequestPhoneChange>(),
              verifyPhoneChange: getIt<VerifyPhoneChange>(),
              requestEmailChange: getIt<RequestEmailChange>(),
              verifyEmailChange: getIt<VerifyEmailChange>(),
            ),
            child: VerifyEmailChangePage(
              userId: extra['userId'] as String,
              email: extra['email'] as String,
            ),
          );
        },
      ),

      // ============================================
      // -------- PASSWORD MANAGEMENT ROUTES --------
      // ============================================
      // 1. Change Password (from Settings) - Step 1: Old Password
      GoRoute(
        path: '/account/change-password',
        name: 'change-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: ChangePasswordPage(userId: extra['userId'] as String),
          );
        },
      ),

      // 2. New Password Page (Reusable for Change & Reset)
      // ⚠️ IMPORTANT: Don't create BlocProvider here, pass cubit via extra
      GoRoute(
        path: '/account/new-password',
        name: 'new-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as ChangePasswordCubit?;

          // If cubit is passed (from change password flow), use BlocProvider.value
          if (cubit != null) {
            return BlocProvider<ChangePasswordCubit>.value(
              value: cubit,
              child: NewPasswordPage(
                userId: extra['userId'] as String?,
                phone: extra['phone'] as String?,
                flow: extra['flow'] as String,
              ),
            );
          }

          // If no cubit (shouldn't happen), create new one
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: NewPasswordPage(
              userId: extra['userId'] as String?,
              phone: extra['phone'] as String?,
              flow: extra['flow'] as String,
            ),
          );
        },
      ),

      // 3. Forgot Password - Phone Entry
      GoRoute(
        path: '/forgot-password-phone',
        name: 'forgot-password-phone',
        builder: (context, state) {
          return const ForgotPasswordPhonePage();
        },
      ),

      // 4. Forgot Password - OTP Verification (Reusing OTP Page)
      GoRoute(
        path: '/otp-forgot-password',
        name: 'otp-forgot-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpVerificationPage(
            phoneNumber: extra['phone'] as String,
            title: extra['title'] as String? ?? 'Atur Ulang Password',
            subtitle:
                extra['subtitle'] as String? ??
                'Masukkan kode OTP yang telah dikirim',
            nextRoute: 'new-password-reset',
            isPasswordReset: true,
          );
        },
      ),

      // 5. New Password after OTP (Reset Flow) - Create new cubit
      GoRoute(
        path: '/new-password-reset',
        name: 'new-password-reset',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => ChangePasswordCubit(
              verifyOldPassword: getIt<VerifyOldPassword>(),
              changePassword: getIt<ChangePassword>(),
              resetPasswordWithOtp: getIt<ResetPasswordWithOtp>(),
            ),
            child: NewPasswordPage(
              phone: extra['phone'] as String,
              flow: 'reset',
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({required this.child, required this.currentPath, super.key});

  int _locationToIndex(String path) {
    if (path.startsWith('/category')) return 1;
    if (path.startsWith('/wishlist')) return 2;
    if (path.startsWith('/account')) return 3;
    return 0;
  }

  static const List<String> _routeNames = [
    'home',
    'category',
    'wishlist',
    'account',
  ];

  void _refreshPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        // Jika HomePage juga pakai BLoC, trigger event di sini
        break;

      case 1: // Category
        // Trigger ulang load categories
        context.read<CategoryBloc>().add(
          const CategoryEventGetAllCategories(1),
        );
        break;

      case 2: // Wishlist
        // Jika Wishlist pakai BLoC, trigger event di sini
        break;

      case 3: // account
        // Jika Account pakai BLoC, trigger event di sini
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) {
          final name = _routeNames[i];

          if (i == currentIndex) {
            // navigasi ke root route tab
            GoRouter.of(context).goNamed(name);

            // trigger refresh jika perlu
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                _refreshPage(context, i);
              } catch (e) {
                // Ignore errors jika bloc tidak tersedia
              }
            });

            return;
          }

          // tap pada tab berbeda -> pindah normal
          GoRouter.of(context).goNamed(name);
        },
      ),
    );
  }
}
