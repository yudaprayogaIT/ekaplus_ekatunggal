// lib/main.dart
import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/cubit/connection_status_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:ekaplus_ekatunggal/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/my_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  Bloc.observer = MyObserver();
  runApp(const EkaplusApp());
}

class EkaplusApp extends StatelessWidget {
  const EkaplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ============================================
        // CONNECTION MONITORING
        // ============================================
        BlocProvider(
          create: (context) => ConnectionCubit()..startMonitoringConnection(),
        ),

        // ============================================
        // 🔥 GLOBAL SINGLETONS (Same pattern as CategoryBloc)
        // These persist across navigation!
        // ============================================

        // Auth Session Cubit
        BlocProvider(
          create: (context) => myinjection<AuthSessionCubit>()..checkSession(),
        ),

        // 🔥 ProductBloc - Global & Persistent (like CategoryBloc)
        BlocProvider(
          create: (context) {
            final productBloc = myinjection<ProductBloc>();
            // Load products once at app start
            productBloc.add(const ProductEventGetAllProducts(1));
            return productBloc;
          },
        ),

        // 🔥 WishlistBloc - Global & Persistent
        BlocProvider(
          create: (context) {
            final wishlistBloc = myinjection<WishlistBloc>();

            // Auto-load wishlist if user is logged in
            final authSessionCubit = context.read<AuthSessionCubit>();
            final authState = authSessionCubit.state;

            if (authState is AuthSessionAuthenticated) {
              wishlistBloc.add(LoadWishlist(authState.user.id));
            }

            return wishlistBloc;
          },
        ),

        // ============================================
        // FACTORY BLOCS (Per Feature - Short-lived)
        // ============================================
        BlocProvider(create: (context) => myinjection<TypeBloc>()),
        BlocProvider(create: (context) => myinjection<CategoryBloc>()),
        BlocProvider(create: (context) => myinjection<AuthBloc>()),
        BlocProvider(create: (context) => myinjection<OtpTimerBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          // Connection listener
          BlocListener<ConnectionCubit, ConnectionStateCubit>(
            listener: (context, state) {
              // Your connection listener code here
            },
          ),

          // 🔥 Auth Session Listener - Sync wishlist with login state
          BlocListener<AuthSessionCubit, AuthSessionState>(
            listener: (context, state) {
              if (state is AuthSessionAuthenticated) {
                // User just logged in - load their wishlist
                context.read<WishlistBloc>().add(LoadWishlist(state.user.id));
                print('✅ Wishlist loaded for user: ${state.user.id}');
              } else if (state is AuthSessionGuest) {
                // User logged out
                print('ℹ️ User logged out');
              }
            },
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: MyRouter().router,
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: AppFonts.primaryFont,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
