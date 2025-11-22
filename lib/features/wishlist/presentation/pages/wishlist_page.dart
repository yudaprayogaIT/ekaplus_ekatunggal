// lib/features/wishlist/presentation/pages/wishlist_page.dart

// import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
// import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
// import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
// import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_header.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_locked_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Wishlist',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        toolbarHeight: 80,
        elevation: 0,
      ),
      body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, authState) {
          final isLoggedIn = authState is AuthSessionAuthenticated;
          final userId = isLoggedIn ? authState.user.id : null;

          return Column(
            children: [
              // const WishlistHeader(),
              Expanded(
                child: isLoggedIn
                    ? WishlistContent(userId: userId!)
                    : const WishlistLockedState(),
              ),
            ],
          );
        },
      ),
    );
  }
}