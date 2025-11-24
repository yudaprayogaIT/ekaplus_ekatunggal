// lib/features/account/presentation/widgets/account_guest_view.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountGuestView extends StatelessWidget {
  const AccountGuestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryYellow = AppColors.secondaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: AppColors.whiteColor,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Image
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 205,
                  height: 135,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/account/account.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Text overlay
              Positioned(
                top: 45,
                right: 0,
                child: SizedBox(
                  width: 240,
                  child: Text(
                    'Mulai jelajahi ribuan produk dari Ekatunggal',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              // MASUK button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.pushNamed('login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: primaryYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'MASUK',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // DAFTAR button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushNamed('register'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: AppColors.whiteColor,
                  ),
                  child: Text(
                    'DAFTAR',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w800,
                      color: primaryYellow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}