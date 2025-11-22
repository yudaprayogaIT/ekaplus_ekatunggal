// lib/features/wishlist/presentation/widgets/wishlist_locked_state.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WishlistLockedState extends StatelessWidget {
  const WishlistLockedState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Spacer(),
            
            SizedBox(
              width: 140,
              height: 140,
              child: Center(
                child: Image.asset(
                  'assets/images/wishlistIcon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_border,
                    size: 120,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Wishlist Anda Masih Kosong\n',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  TextSpan(
                    text: 'Tambahkan produk favorit Anda untuk mengetahui produk lebih detail.',
                  ),
                ],
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.secondaryColor,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jelajahi Produk',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}